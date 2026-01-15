defmodule IagocavalcanteWeb.Plugs.CORS do
  @moduledoc """
  Handles CORS headers for API requests, especially for browser extensions.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_cors_headers()
    |> handle_preflight()
  end

  defp put_cors_headers(conn) do
    origin = get_req_header(conn, "origin") |> List.first()

    conn
    |> put_resp_header("access-control-allow-origin", allowed_origin(origin))
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
    |> put_resp_header(
      "access-control-allow-headers",
      "accept, authorization, content-type, x-requested-with"
    )
    |> put_resp_header("access-control-allow-credentials", "true")
    |> put_resp_header("access-control-max-age", "3600")
  end

  defp handle_preflight(%{method: "OPTIONS"} = conn) do
    conn
    |> send_resp(200, "")
    |> halt()
  end

  defp handle_preflight(conn), do: conn

  defp allowed_origin(origin) do
    case origin do
      # Allow browser extensions
      "chrome-extension://" <> _ -> origin
      "moz-extension://" <> _ -> origin
      # Allow your domain
      "https://iagocavalcante.com" -> origin
      "http://localhost:4000" -> origin
      "http://localhost:3000" -> origin
      # Default to your domain for security
      _ -> "https://iagocavalcante.com"
    end
  end
end
