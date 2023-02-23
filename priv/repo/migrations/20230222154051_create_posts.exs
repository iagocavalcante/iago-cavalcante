defmodule Iagocavalcante.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      timestamps()
    end
  end
end
