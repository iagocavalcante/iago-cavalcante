defmodule Iagocavalcante.BlogTest do
  use Iagocavalcante.DataCase

  alias Iagocavalcante.Blog

  describe "posts" do
    alias Iagocavalcante.Blog.Post

    import Iagocavalcante.BlogFixtures

    @invalid_attrs %{}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Blog.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Blog.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{}

      assert {:ok, %Post{} = post} = Blog.create_post(valid_attrs)
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{}

      assert {:ok, %Post{} = post} = Blog.update_post(post, update_attrs)
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
      assert post == Blog.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Blog.change_post(post)
    end
  end

  describe "comments" do
    alias Iagocavalcante.Blog.Comment
    import Iagocavalcante.BlogFixtures

    @invalid_attrs %{post_id: nil, author_name: nil, author_email: nil, content: nil}

    test "list_comments_for_post/2 returns only approved comments by default" do
      post_id = "test-post"
      comment1 = comment_fixture(%{post_id: post_id})
      comment2 = approved_comment_fixture(%{post_id: post_id})

      # Only approved comments should be returned
      comments = Blog.list_comments_for_post(post_id)
      assert length(comments) == 1
      assert hd(comments).id == comment2.id
      assert hd(comments).status == :approved
    end

    test "list_comments_for_post/2 can filter by status" do
      post_id = "test-post"
      pending_comment = comment_fixture(%{post_id: post_id})
      approved_comment = approved_comment_fixture(%{post_id: post_id})

      # Get pending comments
      pending_comments = Blog.list_comments_for_post(post_id, :pending)
      assert length(pending_comments) == 1
      assert hd(pending_comments).id == pending_comment.id

      # Get approved comments
      approved_comments = Blog.list_comments_for_post(post_id, :approved)
      assert length(approved_comments) == 1
      assert hd(approved_comments).id == approved_comment.id
    end

    test "list_comments_for_post/2 loads nested replies correctly" do
      post_id = "test-post"
      parent_comment = approved_comment_fixture(%{post_id: post_id})

      reply_comment =
        approved_comment_fixture(%{
          post_id: post_id,
          parent_id: parent_comment.id
        })

      comments = Blog.list_comments_for_post(post_id)
      assert length(comments) == 1

      parent = hd(comments)
      assert parent.id == parent_comment.id
      assert length(parent.replies) == 1
      assert hd(parent.replies).id == reply_comment.id
    end

    test "list_comments_for_post/2 only returns top-level comments" do
      post_id = "test-post"
      parent_comment = approved_comment_fixture(%{post_id: post_id})

      reply_comment =
        approved_comment_fixture(%{
          post_id: post_id,
          parent_id: parent_comment.id
        })

      comments = Blog.list_comments_for_post(post_id)
      # Should only return the parent, not the reply as a separate top-level comment
      assert length(comments) == 1
      assert hd(comments).id == parent_comment.id
    end

    test "list_pending_comments/0 returns all pending comments" do
      comment1 = comment_fixture()
      comment2 = approved_comment_fixture()
      comment3 = comment_fixture()

      pending_comments = Blog.list_pending_comments()
      pending_ids = Enum.map(pending_comments, & &1.id)

      assert comment1.id in pending_ids
      assert comment3.id in pending_ids
      assert comment2.id not in pending_ids
    end

    test "create_comment/1 with valid data creates a comment" do
      valid_attrs = %{
        post_id: "test-post",
        author_name: "Jane Doe",
        author_email: "jane@example.com",
        content: "This is a wonderful article! Thanks for sharing your insights.",
        ip_address: "192.168.1.1",
        user_agent: "Mozilla/5.0"
      }

      assert {:ok, %Comment{} = comment} = Blog.create_comment(valid_attrs)
      assert comment.post_id == "test-post"
      assert comment.author_name == "Jane Doe"
      assert comment.author_email == "jane@example.com"
      assert comment.content == "This is a wonderful article! Thanks for sharing your insights."
      assert comment.status == :pending
      assert comment.spam_score >= 0.0
      assert comment.spam_score <= 1.0
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_comment(@invalid_attrs)
    end

    test "create_comment/1 auto-approves low spam score comments from trusted commenters" do
      # First, create some approved comments for this email to make them trusted
      trusted_email = "trusted@example.com"

      for _ <- 1..3 do
        comment = comment_fixture(%{author_email: trusted_email})
        {:ok, _} = Blog.approve_comment(comment.id)
      end

      # Now create a new comment from the trusted email with low spam score
      attrs = %{
        post_id: "test-post",
        author_name: "Trusted User",
        author_email: trusted_email,
        content: "This is a legitimate comment from a trusted user with good content quality.",
        ip_address: "192.168.1.1",
        user_agent: "Mozilla/5.0"
      }

      assert {:ok, %Comment{} = comment} = Blog.create_comment(attrs)
      assert comment.status == :approved
    end

    test "create_comment/1 marks high spam score comments as spam" do
      attrs = %{
        post_id: "test-post",
        author_name: "Spammer",
        author_email: "spam@example.com",
        content:
          "Buy cheap viagra! Free money! Casino discount! http://spam1.com http://spam2.com http://spam3.com http://spam4.com http://spam5.com",
        ip_address: "192.168.1.1",
        user_agent: "Mozilla/5.0"
      }

      assert {:ok, %Comment{} = comment} = Blog.create_comment(attrs)
      assert comment.status == :spam
      assert comment.spam_score >= 0.7
    end

    test "approve_comment/1 approves a pending comment" do
      comment = comment_fixture()
      assert comment.status == :pending

      assert {:ok, %Comment{} = updated_comment} = Blog.approve_comment(comment.id)
      assert updated_comment.status == :approved
    end

    test "reject_comment/1 rejects a pending comment" do
      comment = comment_fixture()
      assert comment.status == :pending

      assert {:ok, %Comment{} = updated_comment} = Blog.reject_comment(comment.id)
      assert updated_comment.status == :rejected
    end

    test "mark_as_spam/1 marks a comment as spam" do
      comment = comment_fixture()

      assert {:ok, %Comment{} = updated_comment} = Blog.mark_as_spam(comment.id)
      assert updated_comment.status == :spam
    end

    test "delete_comment/1 deletes a comment permanently" do
      comment = comment_fixture()

      assert {:ok, %Comment{} = deleted_comment} = Blog.delete_comment(comment.id)
      assert deleted_comment.id == comment.id

      # Verify comment is gone from database
      assert_raise Ecto.NoResultsError, fn -> Blog.get_comment!(comment.id) end
    end

    test "delete_comment/1 raises when comment not found" do
      assert_raise Ecto.NoResultsError, fn -> Blog.delete_comment(99999) end
    end

    test "delete_comment/1 with approved comment removes it from public lists" do
      comment = approved_comment_fixture(%{post_id: "test-post"})

      # Verify comment appears in public list
      comments = Blog.list_comments_for_post("test-post")
      assert length(comments) == 1

      # Delete the comment
      {:ok, _} = Blog.delete_comment(comment.id)

      # Verify comment is gone from public list
      comments = Blog.list_comments_for_post("test-post")
      assert Enum.empty?(comments)
    end

    test "delete_comment/1 with pending comment removes it from pending list" do
      comment = comment_fixture(%{post_id: "test-post"})

      # Verify comment appears in pending list
      pending_comments = Blog.list_pending_comments()
      assert Enum.any?(pending_comments, fn c -> c.id == comment.id end)

      # Delete the comment
      {:ok, _} = Blog.delete_comment(comment.id)

      # Verify comment is gone from pending list
      pending_comments = Blog.list_pending_comments()
      refute Enum.any?(pending_comments, fn c -> c.id == comment.id end)
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      fetched_comment = Blog.get_comment!(comment.id)
      assert fetched_comment.id == comment.id
      assert fetched_comment.author_name == comment.author_name
    end

    test "get_comment!/1 raises when comment not found" do
      assert_raise Ecto.NoResultsError, fn -> Blog.get_comment!(99999) end
    end

    test "comment_count_for_post/1 returns count of approved comments only" do
      post_id = "test-post"
      # pending
      comment1 = comment_fixture(%{post_id: post_id})
      # approved
      comment2 = approved_comment_fixture(%{post_id: post_id})
      # pending
      comment3 = comment_fixture(%{post_id: post_id})
      # spam
      {:ok, _} = Blog.mark_as_spam(comment3.id)

      count = Blog.comment_count_for_post(post_id)
      # Only the approved comment
      assert count == 1
    end

    test "comment_count_for_post/1 includes nested replies in count" do
      post_id = "test-post"
      parent_comment = approved_comment_fixture(%{post_id: post_id})
      reply1 = approved_comment_fixture(%{post_id: post_id, parent_id: parent_comment.id})
      reply2 = approved_comment_fixture(%{post_id: post_id, parent_id: parent_comment.id})

      count = Blog.comment_count_for_post(post_id)
      # parent + 2 replies
      assert count == 3
    end

    test "comment_count_for_post/1 returns 0 for post with no comments" do
      count = Blog.comment_count_for_post("nonexistent-post")
      assert count == 0
    end
  end
end
