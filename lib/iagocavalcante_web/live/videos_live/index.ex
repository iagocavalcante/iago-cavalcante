defmodule IagocavalcanteWeb.VideosLive.Index do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Cloudflare

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    videos = load_videos()
    {:ok,
     socket
     |> assign(:videos, videos)}
  end

  def load_videos do
    req = Cloudflare.req_cloudflare()
    response = Req.get!(req, url: "/stream")
    response.body["result"]
  end

  def cache_videos(videos) do

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
