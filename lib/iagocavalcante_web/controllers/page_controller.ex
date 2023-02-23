defmodule IagocavalcanteWeb.PageController do
  use IagocavalcanteWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
