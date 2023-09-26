defmodule Iagocavalcante.Repo.Migrations.UniqueEmailSubscribers do
  use Ecto.Migration

  def change do
    create unique_index(:subscribers, [:email])
  end
end
