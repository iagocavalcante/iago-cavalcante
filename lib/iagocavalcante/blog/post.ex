defmodule Iagocavalcante.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [])
    |> validate_required([])
  end
end
