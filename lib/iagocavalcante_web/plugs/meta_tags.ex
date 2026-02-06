defmodule IagocavalcanteWeb.Plugs.MetaTags do
  @moduledoc """
  Plug to set dynamic Open Graph and Twitter Card meta tags for article pages.

  For article routes (/articles/:id and /artigos/:id), fetches the post data
  matching the current locale and sets meta tag assigns on the conn.
  The OG description uses a short excerpt from the article body.
  """
  @behaviour Plug

  alias Iagocavalcante.Blog

  @excerpt_length 160

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%{path_info: ["articles", id]} = conn, _opts),
    do: set_article_meta(conn, id, "en", "/articles/")

  def call(%{path_info: ["artigos", id]} = conn, _opts),
    do: set_article_meta(conn, id, "pt_BR", "/artigos/")

  def call(conn, _opts), do: conn

  defp set_article_meta(conn, id, route_locale, path_prefix) do
    locale = conn.assigns[:locale] || route_locale

    case find_post(id, locale) do
      {:ok, post} ->
        excerpt = body_excerpt(post.body)

        conn
        |> Plug.Conn.assign(:meta_title, "#{post.title} · Iago Cavalcante")
        |> Plug.Conn.assign(:meta_description, excerpt)
        |> Plug.Conn.assign(:meta_url, "https://iagocavalcante.com#{path_prefix}#{post.id}")
        |> Plug.Conn.assign(:meta_type, "article")
        |> Plug.Conn.assign(:meta_locale, og_locale(post.locale))

      {:error, :not_found} ->
        conn
    end
  end

  defp find_post(id, locale) do
    case Enum.find(Blog.all_posts(), &(&1.id == id and &1.locale == locale)) do
      nil -> Blog.get_post_by_id(id)
      post -> {:ok, post}
    end
  end

  defp body_excerpt(html) do
    html
    |> String.replace(~r/<[^>]+>/, " ")
    |> String.replace(~r/&[a-zA-Z]+;/, " ")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.slice(0, @excerpt_length)
    |> String.replace(~r/\s\S*$/, "...")
  end

  defp og_locale("pt_BR"), do: "pt_BR"
  defp og_locale(_), do: "en_US"
end
