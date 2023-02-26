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
end
