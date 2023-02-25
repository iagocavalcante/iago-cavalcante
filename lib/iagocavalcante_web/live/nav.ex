defmodule IagocavalcanteWeb.Nav do
  import Phoenix.LiveView
  use Phoenix.Component

  alias IagocavalcanteWeb.{AboutLive, Articles, HomeLive}

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:active_tab, :handle_params, &handle_active_tab_params/3)
     |> attach_hook(:locale, :handle_params, &handle_locale_params/3)
     |> attach_hook(:theme, :handle_params, &handle_theme_params/3)}
  end

  defp handle_active_tab_params(params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {HomeLive, _} ->
          :home

        {AboutLive, _} ->
          :about

        {ArticlesLive, _} ->
          :articles

        {ProjectsLive, _} ->
          :projects

        {_, _} ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end

  defp handle_locale_params(params, _url, socket) do
    locale =
      case params["locale"] do
        "pt_BR" -> "pt_BR"
        _ -> "en"
      end

    {:cont, assign(socket, locale: locale)}
  end

  defp handle_theme_params(params, _url, socket) do
    theme = "light"

    {:cont, assign(socket, theme: theme)}
  end

  defp handle_event(_, _, socket), do: {:cont, socket}
end
