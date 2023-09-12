defmodule Iagocavalcante.Blog.Post do
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
    belongs_to :user, Iagocavalcante.Accounts.User

    timestamps()
  end

  @fields ~w(title slug body published_at status description user_id)a
  @fields_required ~w(title slug body user_id description)a
  @doc false
  def changeset(posts, attrs) do
    posts
    |> cast(attrs, @fields)
    |> validate_required(@fields_required)
  end
end
