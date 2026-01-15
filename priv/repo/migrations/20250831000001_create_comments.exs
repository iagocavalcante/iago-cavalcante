defmodule Iagocavalcante.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :post_id, :string, null: false
      add :author_name, :string, null: false
      add :author_email, :string, null: false
      add :content, :text, null: false
      add :status, :string, default: "pending", null: false
      add :ip_address, :string
      add :user_agent, :text
      add :spam_score, :float, default: 0.0
      add :parent_id, references(:comments, on_delete: :delete_all), null: true

      timestamps()
    end

    create index(:comments, [:post_id])
    create index(:comments, [:status])
    create index(:comments, [:parent_id])
    create index(:comments, [:inserted_at])
    create index(:comments, [:author_email])
  end
end
