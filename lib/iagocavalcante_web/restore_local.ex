defmodule IagocavalcanteWeb.RestoreLocale do
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    locale =
      get_locale(session)
      |> gettext_set()

    {:cont, assign(socket, :locale, locale)}
  end

  defp get_locale(session) do
    session
    |> Map.get("user_locale")
    |> case do
      nil -> "en_us"
      locale -> locale
    end
  end

  defp gettext_set(locale) do
    Gettext.put_locale(IagocavalcanteWeb.Gettext, locale)
    locale
  end
end
