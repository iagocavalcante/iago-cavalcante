defmodule IagocavalcanteWeb.RestoreLocale do
  @moduledoc """
  LiveView hook to restore and persist locale across page navigations.

  On mount, restores the locale from session.
  On toggle_locale event, persists to cookie via JS and reloads the page.
  """
  import Phoenix.LiveView
  use Phoenix.Component

  def on_mount(:default, _params, %{"locale" => locale}, socket) do
    Gettext.put_locale(IagocavalcanteWeb.Gettext, locale)

    {:cont,
     socket
     |> assign(:locale, locale)
     |> attach_hook(:set_locale, :handle_event, &handle_event/3)}
  end

  def on_mount(:default, _params, _session, socket) do
    locale = Gettext.get_locale(IagocavalcanteWeb.Gettext)

    {:cont,
     socket
     |> assign(:locale, locale)
     |> attach_hook(:set_locale, :handle_event, &handle_event/3)}
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

    current_path = get_current_path(socket)

    {:halt,
     socket
     |> assign(:locale, locale)
     |> push_event("set-locale", %{locale: locale})
     |> push_navigate(to: current_path, replace: true)}
  end

  defp get_current_path(socket) do
    case socket.assigns do
      %{__changed__: _, current_path: path} when is_binary(path) -> path
      _ -> URI.parse(Phoenix.LiveView.get_connect_info(socket, :uri) || "/").path || "/"
    end
  rescue
    _ -> "/"
  end
end
