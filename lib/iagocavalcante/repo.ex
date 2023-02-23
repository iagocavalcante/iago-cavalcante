defmodule Iagocavalcante.Repo do
  use Ecto.Repo,
    otp_app: :iagocavalcante,
    adapter: Ecto.Adapters.Postgres
end
