defmodule Iagocavalcante.Blog.CommentNotifierTest do
  use Iagocavalcante.DataCase
  import Swoosh.TestAssertions

  alias Iagocavalcante.Blog.CommentNotifier

  describe "deliver_new_pending_comment/1" do
    test "delivers email notification for new pending comment" do
      comment = %{
        author_name: "John Doe",
        author_email: "john@example.com",
        content: "This is a test comment",
        spam_score: 0.2,
        status: :pending,
        ip_address: "192.168.1.1"
      }

      post = %{
        title: "Test Blog Post",
        id: "test-post"
      }

      {:ok, email} = CommentNotifier.deliver_new_pending_comment(%{comment: comment, post: post})

      assert email.to == [{"", "iagocavalcante@hey.com"}]
      assert email.from == {"", "contato@iagocavalcante.com"}
      assert email.subject == "New Comment Pending Approval - Test Blog Post"
      assert email.text_body =~ "A new comment is pending approval"
      assert email.text_body =~ "John Doe (john@example.com)"
      assert email.text_body =~ "This is a test comment"
      assert email.text_body =~ "Spam Score: 0.2"
      assert email.text_body =~ "Status: pending"
      assert email.text_body =~ "IP Address: 192.168.1.1"
      assert email.text_body =~ "https://iagocavalcante.com/admin/comments"
    end
  end
end
