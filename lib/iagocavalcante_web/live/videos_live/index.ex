defmodule IagocavalcanteWeb.VideosLive.Index do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Clients.Cloudflare.API.Stream

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, videos} = Stream.list_videos()

    {:ok,
     socket
     |> assign(:videos, videos)}
  end

  def duration_to_hour(duration_seconds) do
    hours = trunc(duration_seconds / 3600)
    remaining_seconds = rem(trunc(duration_seconds), 3600)
    minutes = trunc(remaining_seconds / 60)
    seconds = rem(trunc(remaining_seconds), 60)

    if hours == 0 do
      "#{minutes}:#{seconds}"
    else
      "#{hours}:#{minutes}:#{seconds}"
    end
  end
end
