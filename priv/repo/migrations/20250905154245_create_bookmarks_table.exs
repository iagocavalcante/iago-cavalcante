defmodule Iagocavalcante.Repo.Migrations.CreateBookmarksTable do
  use Ecto.Migration

  def change do
    create table(:bookmarks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :url, :text, null: false
      add :description, :text
      add :tags, {:array, :string}, default: []
      add :status, :string, default: "unread", null: false
      add :archived, :boolean, default: false, null: false
      add :favorite, :boolean, default: false, null: false
      add :read_time_minutes, :integer
      add :source, :string, default: "extension", null: false
      add :domain, :string
      add :added_at, :utc_datetime, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:bookmarks, [:user_id])
    create index(:bookmarks, [:domain])
    create index(:bookmarks, [:status])
    create index(:bookmarks, [:added_at])
    create index(:bookmarks, [:tags], using: :gin)
    create unique_index(:bookmarks, [:url, :user_id], name: :bookmarks_url_user_id_index)
  end
end
