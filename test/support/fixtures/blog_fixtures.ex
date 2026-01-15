defmodule Iagocavalcante.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Iagocavalcante.Blog` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    default_attrs = %{
      "slug" => "test-post-#{System.unique_integer([:positive])}",
      "title" => "Test Post Title",
      "description" => "Test post description",
      "body" => "Test post body content",
      "tags" => "test,blog",
      "published" => true,
      "locale" => "en",
      "path" => "test-post-#{System.unique_integer([:positive])}.md",
      "year" => "#{Date.utc_today().year}"
    }

    post_attrs =
      attrs
      |> Enum.into(default_attrs)

    Iagocavalcante.Blog.create_new_post(post_attrs)

    # Since create_new_post doesn't return {:ok, post}, we need to get the created post
    %Iagocavalcante.Post{
      id: post_attrs["slug"],
      title: post_attrs["title"],
      description: post_attrs["description"],
      body: post_attrs["body"],
      tags: String.split(post_attrs["tags"], ",") |> Enum.map(&String.trim/1),
      published: post_attrs["published"],
      date: Date.utc_today(),
      locale: post_attrs["locale"],
      author: "Iago Cavalcante",
      path: post_attrs["path"],
      year: String.to_integer(post_attrs["year"])
    }
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        post_id: "dokploy-simplest-deployment-platform-vps-homelab",
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
        content:
          "Buy cheap viagra! Free money! Click here: http://spam1.com http://spam2.com http://spam3.com http://spam4.com http://spam5.com"
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
