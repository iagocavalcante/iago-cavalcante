defmodule IagocavalcanteWeb.Plugs.Locale do
  @moduledoc """
  Plug to set the locale from various sources.

  Priority order:
  1. URL params (?locale=pt_BR)
  2. Cookie (persisted by JS on locale toggle)
  3. Session (fallback)
  4. Default locale from config
  """
  alias Plug.Conn
  @behaviour Plug

  @locales Gettext.known_locales(IagocavalcanteWeb.Gettext)
  @cookie "phxi18nexamplelanguage"

  defguard known_locale?(locale) when locale in @locales

  @impl Plug
  def init(_opts), do: nil

  @impl Plug
  def call(conn, _opts) do
    locale = fetch_locale(conn)
    Gettext.put_locale(IagocavalcanteWeb.Gettext, locale)

    conn
    |> Conn.assign(:locale, locale)
    |> Conn.put_session("locale", locale)
  end

  defp fetch_locale(conn) do
    locale_from_params(conn) ||
      locale_from_cookies(conn) ||
      locale_from_session(conn) ||
      Gettext.get_locale()
  end

  defp locale_from_params(%Conn{params: %{"locale" => locale}})
       when known_locale?(locale) do
    locale
  end

  defp locale_from_params(_conn), do: nil

  defp locale_from_cookies(%Conn{cookies: %{@cookie => locale}})
       when known_locale?(locale) do
    locale
  end

  defp locale_from_cookies(_conn), do: nil

  defp locale_from_session(conn) do
    case Conn.get_session(conn, "locale") do
      locale when known_locale?(locale) -> locale
      _ -> nil
    end
  end
end
