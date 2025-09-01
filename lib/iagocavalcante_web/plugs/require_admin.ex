defmodule IagocavalcanteWeb.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  @admin_email "iagocavalcante@hey.com"

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && is_admin?(user.email) do
      conn
    else
      conn
      |> put_flash(:error, "Access denied. Admin privileges required.")
      |> redirect(to: "/")
      |> halt()
    end
  end

  defp is_admin?(email) do
    String.downcase(email || "") == String.downcase(@admin_email)
  end

  def is_admin_user?(user) when is_nil(user), do: false
  def is_admin_user?(user), do: is_admin?(user.email)
end