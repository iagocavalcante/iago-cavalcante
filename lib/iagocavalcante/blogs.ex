defmodule Iagocavalcante.Blogs do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Iagocavalcante.Repo

  alias Iagocavalcante.Blog.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  def list_last_posts do
    Repo.all(from p in Post, order_by: [desc: p.inserted_at], limit: 3)
  end

  @doc """
  Gets a single posts.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_posts!(123)
      %Post{}

      iex> get_posts!(456)
      ** (Ecto.NoResultsError)

  """
  def get_posts!(id), do: Repo.get!(Post, id)

  def get_article_by_slug!(slug), do: Repo.get_by!(Post, slug: slug)

  @doc """
  Creates a posts.

  ## Examples

      iex> create_posts(%{field: value})
      {:ok, %Post{}}

      iex> create_posts(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_posts(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a posts.

  ## Examples

      iex> update_posts(posts, %{field: new_value})
      {:ok, %Post{}}

      iex> update_posts(posts, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_posts(%Post{} = posts, attrs) do
    posts
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a posts.

  ## Examples

      iex> delete_posts(posts)
      {:ok, %Post{}}

      iex> delete_posts(posts)
      {:error, %Ecto.Changeset{}}

  """
  def delete_posts(%Post{} = posts) do
    Repo.delete(posts)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking posts changes.

  ## Examples

      iex> change_posts(posts)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_posts(%Post{} = posts, attrs \\ %{}) do
    Post.changeset(posts, attrs)
  end
end
