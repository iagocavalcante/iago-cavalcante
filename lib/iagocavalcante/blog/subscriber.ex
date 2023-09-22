defmodule Iagocavalcante.Blog.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "subscribers" do
    field :email, :string
    field :token, :string
    field :verified_at, :utc_datetime, default: nil

    timestamps()
  end

  @fields ~w(email token verified_at)a
  @fields_required ~w(email)a
  @doc false
  def changeset(posts, attrs) do
    posts
    |> cast(attrs, @fields)
    |> validate_required(@fields_required)
  end
end
