defmodule Iagocavalcante.Repo.Migrations.DropPosts do
  use Ecto.Migration

  def change do
    drop table(:posts)
  end
end
