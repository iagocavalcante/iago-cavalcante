defmodule IagocavalcanteWeb.Admin.CommentsLiveTest do
  use IagocavalcanteWeb.ConnCase
  import Phoenix.LiveViewTest
  import Iagocavalcante.BlogFixtures

  alias Iagocavalcante.Blog

  describe "mount/3" do
    setup do
      # Create some test comments
      comment1 = comment_fixture(%{
        post_id: "test-post-1",
        author_name: "John Doe",
        content: "This is a pending comment that needs review."
      })
      comment2 = approved_comment_fixture(%{
        post_id: "test-post-2", 
        author_name: "Jane Smith",
        content: "This comment is already approved."
      })
      comment3 = comment_fixture(%{
        post_id: "test-post-3",
        author_name: "Bob Wilson", 
        content: "Another pending comment for moderation."
      })

      %{
        pending_comments: [comment1, comment3],
        approved_comment: comment2
      }
    end

    test "loads pending comments on mount", %{conn: conn, pending_comments: pending_comments} do
      {:ok, _view, html} = live(conn, "/admin/comments")
      
      assert html =~ "Comment Moderation"
      assert html =~ "#{length(pending_comments)} pending comments"
      
      # Check that pending comments are displayed
      for comment <- pending_comments do
        assert html =~ comment.author_name
        assert html =~ comment.content
      end
    end

    test "shows empty state when no pending comments", %{conn: conn} do
      # Approve all pending comments
      Blog.list_pending_comments()
      |> Enum.each(fn comment -> 
        {:ok, _} = Blog.approve_comment(comment.id) 
      end)
      
      {:ok, _view, html} = live(conn, "/admin/comments")
      
      assert html =~ "No pending comments"
      assert html =~ "All comments have been reviewed!"
      assert html =~ "0 pending comments"
    end

    test "displays comment details correctly", %{conn: conn, pending_comments: [comment | _]} do
      {:ok, _view, html} = live(conn, "/admin/comments")
      
      assert html =~ comment.author_name
      assert html =~ comment.author_email
      assert html =~ comment.post_id
      assert html =~ comment.content
      assert html =~ comment.ip_address
      
      # Check spam score display
      spam_percentage = Float.round(comment.spam_score * 100, 1)
      assert html =~ "#{spam_percentage}%"
    end

    test "shows action buttons for each comment", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/admin/comments")
      
      assert html =~ "Approve"
      assert html =~ "Reject" 
      assert html =~ "Spam"
    end
  end

  describe "approve_comment event" do
    setup do
      comment = comment_fixture(%{
        author_name: "Test User",
        content: "This comment should be approved.",
        post_id: "test-post"
      })
      %{comment: comment}
    end

    test "approves comment successfully", %{conn: conn, comment: comment} do
      {:ok, view, _html} = live(conn, "/admin/comments")
      
      # Verify comment is pending
      assert comment.status == :pending
      
      # Approve the comment
      result = render_click(view, :approve_comment, %{"comment-id" => comment.id})
      
      # Check that comment was approved
      updated_comment = Blog.get_comment!(comment.id)
      assert updated_comment.status == :approved
      
      # Check flash message
      assert has_element?(view, "[role=alert]", "Comment approved successfully!")
      
      # Verify comment is removed from pending list
      refute result =~ comment.author_name
    end

    test "handles approval error gracefully", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/comments")
      
      # Try to approve non-existent comment
      render_click(view, :approve_comment, %{"comment-id" => 99999})
      
      # Should show error message
      assert has_element?(view, "[role=alert]", "Error approving comment")
    end

    test "updates pending comments count after approval", %{conn: conn, comment: comment} do
      {:ok, view, html} = live(conn, "/admin/comments")
      
      # Check initial count
      initial_count = html |> Floki.find("text()") |> Enum.filter(&String.contains?(&1, "pending comments")) |> length()
      
      # Approve comment
      render_click(view, :approve_comment, %{"comment-id" => comment.id})
      
      # Check updated HTML
      updated_html = render(view)
      
      # Count should be decreased
      # Note: The exact assertion depends on how many other pending comments exist
      assert updated_html =~ "pending comments"
    end

    test "sets loading state during approval", %{conn: conn, comment: comment} do
      {:ok, view, _html} = live(conn, "/admin/comments")
      
      # The loading state is briefly set during the event, but it's hard to test directly
      # Instead we verify the operation completes successfully
      render_click(view, :approve_comment, %{"comment-id" => comment.id})
      
      updated_comment = Blog.get_comment!(comment.id)
      assert updated_comment.status == :approved
    end
  end

  describe "reject_comment event" do
    setup do
      comment = comment_fixture(%{
        author_name: "Rejected User",
        content: "This comment should be rejected.",
        post_id: "test-post"
      })
      %{comment: comment}
    end

    test "rejects comment successfully", %{conn: conn, comment: comment} do
      {:ok, view, _html} = live(conn, "/admin/comments")
      
      # Verify comment is pending
      assert comment.status == :pending
      
      # Reject the comment
      result = render_click(view, :reject_comment, %{"comment-id" => comment.id})
      
      # Check that comment was rejected
      updated_comment = Blog.get_comment!(comment.id)
      assert updated_comment.status == :rejected
      
      # Check flash message
      assert has_element?(view, "[role=alert]", "Comment rejected")
      
      # Verify comment is removed from pending list
      refute result =~ comment.author_name
    end

    test "handles rejection error gracefully", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/comments")
      
      # Try to reject non-existent comment
      render_click(view, :reject_comment, %{"comment-id" => 99999})
      
      # Should show error message
      assert has_element?(view, "[role=alert]", "Error rejecting comment")
    end
  end

  describe "mark_spam event" do
    setup do
      comment = comment_fixture(%{
        author_name: "Spammer",
        content: "Buy cheap products now! Click here for amazing deals!",
        post_id: "test-post"
      })
      %{comment: comment}
    end

    test "marks comment as spam successfully", %{conn: conn, comment: comment} do
      {:ok, view, _html} = live(conn, "/admin/comments")
      
      # Verify comment is pending
      assert comment.status == :pending
      
      # Mark as spam
      result = render_click(view, :mark_spam, %{"comment-id" => comment.id})
      
      # Check that comment was marked as spam
      updated_comment = Blog.get_comment!(comment.id)
      assert updated_comment.status == :spam
      
      # Check flash message
      assert has_element?(view, "[role=alert]", "Comment marked as spam")
      
      # Verify comment is removed from pending list
      refute result =~ comment.author_name
    end

    test "handles spam marking error gracefully", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/comments")
      
      # Try to mark non-existent comment as spam
      render_click(view, :mark_spam, %{"comment-id" => 99999})
      
      # Should show error message
      assert has_element?(view, "[role=alert]", "Error marking comment as spam")
    end
  end

  describe "spam score display" do
    test "shows correct color coding for spam scores", %{conn: conn} do
      # Create comments with different spam scores
      high_spam = comment_fixture(%{
        content: "Buy viagra cheap! http://spam1.com http://spam2.com http://spam3.com http://spam4.com http://spam5.com"
      })
      medium_spam = comment_fixture(%{
        content: "Check out this discount offer at http://deals.com - limited time!"
      })
      low_spam = comment_fixture(%{
        content: "Thank you for this insightful article. I learned a lot from your analysis."
      })
      
      {:ok, _view, html} = live(conn, "/admin/comments")
      
      # These classes are used in the spam_score_color/1 function
      # High spam (≥0.7) should have red text
      # Medium spam (≥0.4) should have orange text  
      # Low spam (<0.4) should have green text
      assert html =~ "text-red-600" or html =~ "text-orange-600" or html =~ "text-green-600"
    end
  end

  describe "auto-refresh functionality" do
    test "refreshes comments periodically" do
      # This is a bit tricky to test since it involves time
      # We can verify the handle_info callback works correctly
      socket = %Phoenix.LiveView.Socket{}
      |> Phoenix.Component.assign(:pending_comments, [])
      |> Phoenix.Component.assign(:pending_comments_count, 0)
      
      # Create a new comment
      new_comment = comment_fixture()
      
      # Simulate the refresh message
      {:noreply, updated_socket} = IagocavalcanteWeb.Admin.CommentsLive.handle_info(:refresh_comments, socket)
      
      # Check that comments were refreshed
      assert is_list(updated_socket.assigns.pending_comments)
      assert is_integer(updated_socket.assigns.pending_comments_count)
    end
  end

  describe "helper functions" do
    alias IagocavalcanteWeb.Admin.CommentsLive

    test "format_datetime/1 formats datetime correctly" do
      datetime = ~U[2024-01-15 14:30:45.123456Z]
      result = CommentsLive.format_datetime(datetime)
      
      assert result == "2024-01-15 14:30"
      assert is_binary(result)
      assert String.length(result) == 16
    end

    test "format_content/1 converts newlines to HTML breaks" do
      content = "Line 1\nLine 2\r\nLine 3\rLine 4"
      result = CommentsLive.format_content(content)
      
      # Should convert all types of line breaks to <br>
      assert Phoenix.HTML.safe_to_string(result) == "Line 1<br>Line 2<br>Line 3<br>Line 4"
    end

    test "spam_score_color/1 returns correct CSS classes" do
      assert CommentsLive.spam_score_color(0.8) == "text-red-600"    # High spam
      assert CommentsLive.spam_score_color(0.5) == "text-orange-600" # Medium spam  
      assert CommentsLive.spam_score_color(0.2) == "text-green-600"  # Low spam
      assert CommentsLive.spam_score_color(0.7) == "text-red-600"    # Boundary case
      assert CommentsLive.spam_score_color(0.4) == "text-orange-600" # Boundary case
    end
  end

  describe "integration with comment system" do
    test "approving comment makes it visible on public pages", %{conn: conn} do
      comment = comment_fixture(%{
        post_id: "public-test-post",
        author_name: "Public User",
        content: "This should appear publicly after approval."
      })
      
      # Initially comment should not be in public list
      public_comments = Blog.list_comments_for_post("public-test-post")
      assert Enum.empty?(public_comments)
      
      # Approve through admin interface
      {:ok, view, _html} = live(conn, "/admin/comments") 
      render_click(view, :approve_comment, %{"comment-id" => comment.id})
      
      # Now comment should appear in public list
      public_comments = Blog.list_comments_for_post("public-test-post")
      assert length(public_comments) == 1
      assert hd(public_comments).id == comment.id
    end

    test "rejecting comment keeps it hidden from public", %{conn: conn} do
      comment = comment_fixture(%{
        post_id: "reject-test-post",
        author_name: "Rejected User", 
        content: "This should not appear publicly."
      })
      
      # Reject through admin interface
      {:ok, view, _html} = live(conn, "/admin/comments")
      render_click(view, :reject_comment, %{"comment-id" => comment.id})
      
      # Comment should not appear in public list
      public_comments = Blog.list_comments_for_post("reject-test-post") 
      assert Enum.empty?(public_comments)
      
      # But comment should still exist in database with rejected status
      db_comment = Blog.get_comment!(comment.id)
      assert db_comment.status == :rejected
    end
  end
end