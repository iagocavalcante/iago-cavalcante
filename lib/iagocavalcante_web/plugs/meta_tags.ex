defmodule IagocavalcanteWeb.Plugs.MetaTags do
  @moduledoc """
  Plug to set dynamic Open Graph and Twitter Card meta tags for article pages.

  For article routes (/articles/:id and /artigos/:id), fetches the post data
  and sets meta tag assigns on the conn. The root layout uses these assigns
  with fallbacks to default values.
  """
  @behaviour Plug

  alias Iagocavalcante.Blog

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%{path_info: ["articles", id]} = conn, _opts), do: set_article_meta(conn, id)
  def call(%{path_info: ["artigos", id]} = conn, _opts), do: set_article_meta(conn, id)
  def call(conn, _opts), do: conn

  defp set_article_meta(conn, id) do
    case Blog.get_post_by_id(id) do
      {:ok, post} ->
        conn
        |> Plug.Conn.assign(:meta_title, "#{post.title} · Iago Cavalcante")
        |> Plug.Conn.assign(:meta_description, post.description)
        |> Plug.Conn.assign(:meta_url, "https://iagocavalcante.com/articles/#{post.id}")
        |> Plug.Conn.assign(:meta_type, "article")

      {:error, :not_found} ->
        conn
    end
  end
end
