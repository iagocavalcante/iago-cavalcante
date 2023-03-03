defmodule IagocavalcanteWeb.RestoreLocale do
  import Phoenix.LiveView
  use Phoenix.Component

  import IagocavalcanteWeb.Gettext

  def on_mount(:default, _params, %{"locale" => locale}, socket) do
    Gettext.put_locale(IagocavalcanteWeb.Gettext, locale)

    {:cont,
     socket
     |> assign(:locale, locale)
     |> attach_hook(:set_locale, :handle_event, &handle_event/3)}
  end

  def on_mount(:default, _params, _session, socket), do: {:cont, socket}

  defp handle_event("toggle_locale", %{"locale" => "en"}, socket) do
    locale = "pt_BR"
    IO.inspect(locale, label: "handle_set_locale")
    perform_assigns(socket, locale)
  end

  defp handle_event("toggle_locale", %{"locale" => "pt_BR"}, socket) do
    locale = "en"
    IO.inspect(locale, label: "handle_set_locale")
    perform_assigns(socket, locale)
  end

  defp handle_event(_, _, socket) do
    {:cont, socket}
  end

  defp perform_assigns(socket, locale) do
    IO.inspect(locale, label: "perform_assigns")

    # current_path = choose_path(socket.view)
    # remove / from the beginning of the path
    # current_path = String.replace(current_path, "/", "")
    Gettext.put_locale(IagocavalcanteWeb.Gettext, locale)
    {:halt, socket |> assign(locale: locale)}
  end
end
