defmodule Iagocavalcante.Repo.Migrations.CreateSubscriber do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :email, :string
      add :token, :string
      add :verified_at, :utc_datetime, default: nil

      timestamps()
    end
  end
end
