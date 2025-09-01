defmodule Iagocavalcante.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Iagocavalcante.Blog` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{})
      |> Iagocavalcante.Blog.create_post()

    post
  end

  @doc """
  Generate a posts.
  """
  def posts_fixture(attrs \\ %{}) do
    {:ok, posts} =
      attrs
      |> Enum.into(%{})
      |> Iagocavalcante.Blog.create_posts()

    posts
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        post_id: "test-post-#{System.unique_integer([:positive])}",
        author_name: "Test Author",
        author_email: "test#{System.unique_integer([:positive])}@example.com",
        content: "This is a test comment with enough content to pass validation requirements.",
        ip_address: "127.0.0.1",
        user_agent: "Test User Agent"
      })
      |> Iagocavalcante.Blog.create_comment()

    comment
  end

  @doc """
  Generate a comment with approved status.
  """
  def approved_comment_fixture(attrs \\ %{}) do
    comment = comment_fixture(attrs)
    {:ok, comment} = Iagocavalcante.Blog.approve_comment(comment.id)
    comment
  end

  @doc """
  Generate a spam comment.
  """
  def spam_comment_fixture(attrs \\ %{}) do
    attrs = 
      attrs
      |> Enum.into(%{
        content: "Buy cheap viagra! Free money! Click here: http://spam1.com http://spam2.com http://spam3.com http://spam4.com http://spam5.com"
      })
    
    comment_fixture(attrs)
  end

  @doc """
  Generate a reply comment.
  """
  def reply_comment_fixture(parent_comment, attrs \\ %{}) do
    attrs = 
      attrs
      |> Enum.into(%{
        post_id: parent_comment.post_id,
        parent_id: parent_comment.id,
        content: "This is a reply to the parent comment with sufficient length for validation."
      })
    
    comment_fixture(attrs)
  end
end
