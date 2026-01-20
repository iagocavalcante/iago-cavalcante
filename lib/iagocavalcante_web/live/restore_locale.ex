defmodule IagocavalcanteWeb.RestoreLocale do
  @moduledoc """
  LiveView hook to restore and persist locale across page navigations.

  On mount, restores the locale from session and stores current URI.
  On toggle_locale event, redirects with locale param to persist change.
  """
  import Phoenix.LiveView
  use Phoenix.Component

  def on_mount(:default, _params, %{"locale" => locale}, socket) do
    Gettext.put_locale(IagocavalcanteWeb.Gettext, locale)

    {:cont,
     socket
     |> assign(:locale, locale)
     |> attach_hook(:set_locale, :handle_event, &handle_event/3)
     |> attach_hook(:save_uri, :handle_params, &save_current_uri/3)}
  end

  def on_mount(:default, _params, _session, socket) do
    locale = Gettext.get_locale(IagocavalcanteWeb.Gettext)

    {:cont,
     socket
     |> assign(:locale, locale)
     |> attach_hook(:set_locale, :handle_event, &handle_event/3)
     |> attach_hook(:save_uri, :handle_params, &save_current_uri/3)}
  end

  defp save_current_uri(_params, uri, socket) do
    {:cont, assign(socket, :current_uri, uri)}
  end

  defp handle_event("toggle_locale", %{"locale" => current_locale}, socket) do
    new_locale = toggle_locale(current_locale)
    persist_and_reload(socket, new_locale)
  end

  defp handle_event(_, _, socket), do: {:cont, socket}

  defp toggle_locale("en"), do: "pt_BR"
  defp toggle_locale("pt_BR"), do: "en"
  defp toggle_locale(_), do: "en"

  defp persist_and_reload(socket, locale) do
    Gettext.put_locale(IagocavalcanteWeb.Gettext, locale)

    # Get current path, fallback to home
    current_path =
      case socket.assigns[:current_uri] do
        uri when is_binary(uri) -> URI.parse(uri).path || "/"
        _ -> "/"
      end

    # Build redirect URL with locale param
    redirect_url = "#{current_path}?locale=#{locale}"

    # Push event to set cookie for future navigations, then redirect
    # Redirect forces full HTTP request so Plug reads the locale param
    {:halt,
     socket
     |> push_event("set-locale", %{locale: locale})
     |> redirect(to: redirect_url)}
  end
end
