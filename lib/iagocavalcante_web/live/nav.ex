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
     |> attach_hook(:ff, :handle_params, &handle_feature_flags/3)}
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

        {VideosLive.Index, _} ->
          :videos

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

  defp handle_feature_flags(_params, _url, socket) do
    ff_donate = Application.get_env(:iagocavalcante, :ff_donate)
    ff_video = Application.get_env(:iagocavalcante, :ff_video)

    {:cont, assign(socket, ff: %{
      donate: ff_donate |> String.to_integer,
      video: ff_video |> String.to_integer
    })}
  end

  defp maybe_locale(socket) do
    case socket.assigns[:locale] do
      nil -> "en"
      _ -> socket.assigns.locale
    end
  end
end
