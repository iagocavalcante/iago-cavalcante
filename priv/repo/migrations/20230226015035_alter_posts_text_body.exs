defmodule Iagocavalcante.Repo.Migrations.AlterPostsTextBody do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify :body, :text
      add :description, :text
    end
  end
end
