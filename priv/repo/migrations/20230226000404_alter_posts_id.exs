defmodule Iagocavalcante.Repo.Migrations.AlterPostsId do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :id, :id, primary_key: true
    end
  end
end
