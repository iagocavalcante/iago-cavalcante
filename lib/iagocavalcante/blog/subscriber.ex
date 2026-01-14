defmodule Iagocavalcante.Blog.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  alias Iagocavalcante.Ecto.Sanitizer

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
  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, @fields)
    |> Sanitizer.sanitize_fields([:email])
    |> validate_required(@fields_required)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end
end
