defmodule Iagocavalcante.Blog.CommentNotifier do
  @moduledoc """
  Module responsible for sending email notifications related to comments.
  """

  import Swoosh.Email

  alias Iagocavalcante.Mailer

  @admin_email "iagocavalcante@hey.com"
  @from_email "contato@iagocavalcante.com"

  @doc """
  Deliver email notification to admin about a new pending comment.
  """
  def deliver_new_pending_comment(%{comment: comment, post: post}) do
    email =
      new()
      |> to(@admin_email)
      |> from(@from_email)
      |> subject("New Comment Pending Approval - #{post.title}")
      |> text_body(new_pending_comment_text(comment, post))

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  defp new_pending_comment_text(comment, post) do
    """
    A new comment is pending approval on your blog.

    Post: #{post.title}
    Author: #{comment.author_name} (#{comment.author_email})

    Comment:
    #{comment.content}

    Spam Score: #{comment.spam_score}
    Status: #{comment.status}
    IP Address: #{comment.ip_address || "Not recorded"}

    Review and moderate this comment at:
    https://iagocavalcante.com/admin/comments

    --
    Iago Cavalcante Blog
    """
  end
end
