defmodule IagocavalcanteWeb.Plugs.ApiAuth do
  @moduledoc """
  Authentication plug specifically for API endpoints.
  Returns JSON errors instead of redirecting to login pages.
  """

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Authentication required"})
      |> halt()
    end
  end
end
