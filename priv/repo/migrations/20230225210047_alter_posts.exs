defmodule Iagocavalcante.Repo.Migrations.AlterPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :title, :string
      add :slug, :string
      add :body, :string
      add :published_at, :utc_datetime
      add :status, :string
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
