defmodule IagocavalcanteWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid HTTP responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use IagocavalcanteWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: IagocavalcanteWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: IagocavalcanteWeb.ErrorJSON)
    |> render(:"404")
  end

  # Handle unauthorized access
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: IagocavalcanteWeb.ErrorJSON)
    |> render(:"401")
  end

  # Handle forbidden access
  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: IagocavalcanteWeb.ErrorJSON)
    |> render(:"403")
  end

  # Handle validation errors
  def call(conn, {:error, :bad_request, message}) when is_binary(message) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: message})
  end

  # Handle rate limiting
  def call(conn, {:error, :too_many_requests}) do
    conn
    |> put_status(:too_many_requests)
    |> json(%{error: "Rate limit exceeded. Please try again later."})
  end

  # Generic error handler
  def call(conn, {:error, reason}) when is_atom(reason) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: "Internal server error"})
  end
end
