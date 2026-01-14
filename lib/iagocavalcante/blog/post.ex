defmodule Iagocavalcante.Blog.Post do
  @moduledoc """
  Schema for dynamic blog posts stored in the database.

  Note: user_id is stored as a plain field to avoid cross-context coupling.
  Use Accounts.get_user!/1 when you need user data.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "posts" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :body, :string
    field :published_at, :utc_datetime, default: nil
    field :status, Ecto.Enum, values: [:draft, :published, :archived], default: :draft
    # Store user_id as plain field - avoids cross-context coupling
    field :user_id, :id

    timestamps()
  end

  @fields ~w(title slug body published_at status description user_id)a
  @fields_required ~w(title slug body user_id description)a

  @doc """
  Default changeset for creating/updating posts.
  """
  def changeset(post, attrs) do
    post
    |> cast(attrs, @fields)
    |> validate_required(@fields_required)
    |> validate_length(:title, min: 1, max: 200)
    |> validate_length(:description, max: 500)
    |> validate_length(:slug, min: 1, max: 100)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must contain only lowercase letters, numbers, and hyphens"
    )
    |> unique_constraint(:slug)
  end

  @doc """
  Changeset for publishing a post.
  """
  def publish_changeset(post) do
    post
    |> change(%{status: :published, published_at: DateTime.utc_now()})
  end

  @doc """
  Changeset for archiving a post.
  """
  def archive_changeset(post) do
    post
    |> change(%{status: :archived})
  end
end
