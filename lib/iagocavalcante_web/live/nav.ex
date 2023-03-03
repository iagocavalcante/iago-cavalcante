defmodule IagocavalcanteWeb.Nav do
  import Phoenix.LiveView
  use Phoenix.Component

  import IagocavalcanteWeb.Gettext

  alias IagocavalcanteWeb.AboutLive
  alias IagocavalcanteWeb.ArticlesLive
  alias IagocavalcanteWeb.HomeLive
  alias IagocavalcanteWeb.ProjectsLive
  alias IagocavalcanteWeb.SpeakingLive
  alias IagocavalcanteWeb.UsesLive

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> assign(locale: maybe_locale(socket))
     |> attach_hook(:active_tab, :handle_params, &handle_active_tab_params/3)
     |> attach_hook(:theme, :handle_params, &handle_theme_params/3)}
  end

  defp handle_active_tab_params(_params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {HomeLive, _} ->
          :home

        {AboutLive, _} ->
          :about

        {ArticlesLive.Index, _} ->
          :articles

        {ArticlesLive.Show, _} ->
          :articles

        {ProjectsLive, _} ->
          :projects

        {SpeakingLive, _} ->
          :speaking

        {UsesLive, _} ->
          :uses

        {_, _} ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end

  defp handle_theme_params(_params, _url, socket) do
    theme = "light"

    {:cont, assign(socket, theme: theme)}
  end

  defp maybe_locale(socket) do
    IO.inspect(socket.assigns)

    case socket.assigns[:locale] do
      nil -> "en"
      _ -> socket.assigns.locale
    end
  end
end
