defmodule IagocavalcanteWeb.API.HealthController do
  use IagocavalcanteWeb, :controller

  def check(conn, _params) do
    json(conn, %{
      status: "ok",
      timestamp: DateTime.utc_now(),
      version: "1.0.0"
    })
  end
end
