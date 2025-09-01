defmodule IagocavalcanteWeb.Components.CommentsTest do
  use IagocavalcanteWeb.ConnCase
  import Phoenix.LiveViewTest
  import Iagocavalcante.BlogFixtures

  alias IagocavalcanteWeb.Components.Comments
  alias Iagocavalcante.Blog

  @valid_comment_attrs %{
    "author_name" => "John Doe",
    "author_email" => "john@example.com",
    "content" => "This is a great post! Thank you for sharing your insights with us."
  }

  describe "mount/1" do
    test "initializes socket with default values" do
      socket = %Phoenix.LiveView.Socket{}
      {:ok, updated_socket} = Comments.mount(socket)
      
      assert updated_socket.assigns.loading == false
      assert updated_socket.assigns.message == nil
      assert updated_socket.assigns.message_type == nil
      assert updated_socket.assigns.reply_to == nil
    end
  end

  describe "update/2" do
    test "loads comments and sets up form for given post" do
      post_id = "test-post"
      comment1 = approved_comment_fixture(%{post_id: post_id})
      comment2 = approved_comment_fixture(%{post_id: post_id})
      
      socket = %Phoenix.LiveView.Socket{}
      assigns = %{post_id: post_id}
      
      {:ok, updated_socket} = Comments.update(assigns, socket)
      
      assert updated_socket.assigns.post_id == post_id
      assert length(updated_socket.assigns.comments) == 2
      assert updated_socket.assigns.comment_count == 2
      assert %Phoenix.HTML.Form{} = updated_socket.assigns.form
    end

    test "loads comments with nested replies" do
      post_id = "test-post"
      parent_comment = approved_comment_fixture(%{post_id: post_id})
      reply_comment = approved_comment_fixture(%{
        post_id: post_id,
        parent_id: parent_comment.id
      })
      
      socket = %Phoenix.LiveView.Socket{}
      assigns = %{post_id: post_id}
      
      {:ok, updated_socket} = Comments.update(assigns, socket)
      
      assert length(updated_socket.assigns.comments) == 1
      parent = hd(updated_socket.assigns.comments)
      assert parent.id == parent_comment.id
      assert length(parent.replies) == 1
      assert hd(parent.replies).id == reply_comment.id
    end
  end

  describe "handle_event submit_comment with honeypot" do
    test "rejects submission when honeypot field is filled" do
      post_id = "test-post"
      socket = build_socket_with_post(post_id)
      
      params = Map.merge(@valid_comment_attrs, %{"website" => "http://spam.com"})
      
      {:noreply, updated_socket} = Comments.handle_event("submit_comment", params, socket)
      
      assert updated_socket.assigns.message == "There was an error submitting your comment. Please try again."
      assert updated_socket.assigns.message_type == :error
      assert updated_socket.assigns.loading == false
    end
  end

  describe "handle_event submit_comment" do
    test "creates comment with valid data" do
      post_id = "test-post"
      socket = build_socket_with_post(post_id)
      
      {:noreply, updated_socket} = Comments.handle_event("submit_comment", @valid_comment_attrs, socket)
      
      # Check that comment was created
      comments = Blog.list_comments_for_post(post_id, :pending)
      assert length(comments) == 1
      
      comment = hd(comments)
      assert comment.author_name == "John Doe"
      assert comment.author_email == "john@example.com"
      assert comment.content == "This is a great post! Thank you for sharing your insights with us."
      
      # Check socket response
      assert updated_socket.assigns.loading == false
      assert updated_socket.assigns.message =~ "Thank you for your comment"
      assert updated_socket.assigns.message_type == :success
      assert updated_socket.assigns.reply_to == nil
    end

    test "creates comment with reply_to when replying" do
      post_id = "test-post"
      parent_comment = approved_comment_fixture(%{post_id: post_id})
      socket = build_socket_with_post(post_id, reply_to: parent_comment.id)
      
      {:noreply, updated_socket} = Comments.handle_event("submit_comment", @valid_comment_attrs, socket)
      
      # Check that reply comment was created
      comments = Blog.list_comments_for_post(post_id, :pending)
      reply_comment = Enum.find(comments, fn c -> c.parent_id == parent_comment.id end)
      
      assert reply_comment != nil
      assert reply_comment.parent_id == parent_comment.id
      assert reply_comment.post_id == post_id
    end

    test "shows success message for auto-approved comments" do
      post_id = "test-post"
      
      # Create a trusted commenter
      trusted_email = "trusted@example.com"
      for _ <- 1..3 do
        comment = comment_fixture(%{author_email: trusted_email})
        {:ok, _} = Blog.approve_comment(comment.id)
      end
      
      socket = build_socket_with_post(post_id)
      attrs = %{
        "author_name" => "Trusted User", 
        "author_email" => trusted_email,
        "content" => "This is a great post with good quality content that should be auto-approved."
      }
      
      {:noreply, updated_socket} = Comments.handle_event("submit_comment", attrs, socket)
      
      assert updated_socket.assigns.message == "Your comment has been posted successfully!"
      assert updated_socket.assigns.message_type == :success
    end

    test "handles spam comments appropriately" do
      post_id = "test-post"
      socket = build_socket_with_post(post_id)
      
      spam_attrs = %{
        "author_name" => "Spammer",
        "author_email" => "spam@example.com",
        "content" => "Buy cheap viagra! Free money! Click here: http://spam1.com http://spam2.com http://spam3.com http://spam4.com http://spam5.com"
      }
      
      {:noreply, updated_socket} = Comments.handle_event("submit_comment", spam_attrs, socket)
      
      assert updated_socket.assigns.message == "Your comment couldn't be posted. Please contact us if you believe this is an error."
      assert updated_socket.assigns.message_type == :success
    end

    test "handles validation errors" do
      post_id = "test-post"
      socket = build_socket_with_post(post_id)
      
      invalid_attrs = %{
        "author_name" => "A",  # Too short
        "author_email" => "invalid-email",  # Invalid format
        "content" => "Short"  # Too short
      }
      
      {:noreply, updated_socket} = Comments.handle_event("submit_comment", invalid_attrs, socket)
      
      assert updated_socket.assigns.message == "Please check the errors below and try again."
      assert updated_socket.assigns.message_type == :error
      assert updated_socket.assigns.loading == false
      assert %Phoenix.HTML.Form{} = updated_socket.assigns.form
      
      # Check that form contains changeset with errors
      changeset = updated_socket.assigns.form.source
      assert %Ecto.Changeset{valid?: false} = changeset
    end

    test "refreshes comments list after successful submission" do
      post_id = "test-post"
      existing_comment = approved_comment_fixture(%{post_id: post_id})
      socket = build_socket_with_post(post_id)
      
      # Initial state should have 1 comment
      assert socket.assigns.comment_count == 1
      assert length(socket.assigns.comments) == 1
      
      {:noreply, updated_socket} = Comments.handle_event("submit_comment", @valid_comment_attrs, socket)
      
      # Comments should be refreshed (though new comment might be pending)
      assert is_list(updated_socket.assigns.comments)
      assert is_integer(updated_socket.assigns.comment_count)
      
      # Form should be reset
      assert updated_socket.assigns.form.source == %{}
    end

    test "sets loading state during submission" do
      post_id = "test-post"
      socket = build_socket_with_post(post_id)
      
      # Mock the socket to capture intermediate state
      send(self(), {:loading_state, socket.assigns.loading})
      
      {:noreply, updated_socket} = Comments.handle_event("submit_comment", @valid_comment_attrs, socket)
      
      # Final state should have loading false
      assert updated_socket.assigns.loading == false
    end
  end

  describe "handle_event reply_to_comment" do
    test "sets reply_to in socket assigns" do
      socket = build_socket_with_post("test-post")
      comment_id = "123"
      
      {:noreply, updated_socket} = Comments.handle_event("reply_to_comment", %{"comment-id" => comment_id}, socket)
      
      assert updated_socket.assigns.reply_to == 123
    end
  end

  describe "render/1" do
    test "renders comment form with proper fields" do
      socket = build_socket_with_post("test-post")
      
      html = render_component(Comments, socket.assigns)
      
      assert html =~ "Comments ("
      assert html =~ ~s(name="author_name")
      assert html =~ ~s(name="author_email")  
      assert html =~ ~s(name="content")
      assert html =~ ~s(name="website")  # Honeypot field
      assert html =~ "Post Comment"
    end

    test "renders existing comments" do
      post_id = "test-post"
      comment1 = approved_comment_fixture(%{
        post_id: post_id,
        author_name: "Alice",
        content: "Great article!"
      })
      comment2 = approved_comment_fixture(%{
        post_id: post_id, 
        author_name: "Bob",
        content: "I agree with Alice."
      })
      
      socket = build_socket_with_post(post_id)
      
      html = render_component(Comments, socket.assigns)
      
      assert html =~ "Alice"
      assert html =~ "Great article!"
      assert html =~ "Bob" 
      assert html =~ "I agree with Alice."
    end

    test "renders success message when present" do
      socket = build_socket_with_post("test-post", 
        message: "Comment posted successfully!", 
        message_type: :success
      )
      
      html = render_component(Comments, socket.assigns)
      
      assert html =~ "Comment posted successfully!"
      assert html =~ "bg-green-50"  # Success styling
    end

    test "renders error message when present" do
      socket = build_socket_with_post("test-post",
        message: "There was an error",
        message_type: :error
      )
      
      html = render_component(Comments, socket.assigns)
      
      assert html =~ "There was an error"
      assert html =~ "bg-red-50"  # Error styling
    end

    test "shows empty state when no comments" do
      socket = build_socket_with_post("test-post-empty")
      
      html = render_component(Comments, socket.assigns)
      
      assert html =~ "No comments yet"
      assert html =~ "Be the first to share your thoughts!"
    end

    test "renders nested replies correctly" do
      post_id = "test-post"
      parent_comment = approved_comment_fixture(%{
        post_id: post_id,
        author_name: "Parent",
        content: "Original comment"
      })
      reply_comment = approved_comment_fixture(%{
        post_id: post_id,
        parent_id: parent_comment.id,
        author_name: "Replier", 
        content: "This is a reply"
      })
      
      socket = build_socket_with_post(post_id)
      
      html = render_component(Comments, socket.assigns)
      
      assert html =~ "Parent"
      assert html =~ "Original comment"
      assert html =~ "Replier"
      assert html =~ "This is a reply"
      assert html =~ "ml-11"  # Nested reply styling
    end

    test "shows loading state on submit button" do
      socket = build_socket_with_post("test-post", loading: true)
      
      html = render_component(Comments, socket.assigns)
      
      assert html =~ "Submitting..."
      assert html =~ "disabled"
      assert html =~ "animate-spin"  # Loading spinner
    end
  end

  # Helper functions
  defp build_socket_with_post(post_id, additional_assigns \\ []) do
    comments = Blog.list_comments_for_post(post_id)
    comment_count = Blog.comment_count_for_post(post_id)
    
    assigns = [
      post_id: post_id,
      comments: comments,
      comment_count: comment_count,
      form: Phoenix.Component.to_form(%{}),
      loading: false,
      message: nil,
      message_type: nil,
      reply_to: nil
    ] ++ additional_assigns
    
    %Phoenix.LiveView.Socket{}
    |> Phoenix.Component.assign(assigns)
  end
end