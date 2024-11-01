defmodule IagocavalcanteWeb.VideosLive.Show do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Clients.Cloudflare.API

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    video = get_video_details(id)
    video_embeded = video["preview"] |> String.replace("watch", "iframe")
    video = Map.put(video, "embeded", video_embeded)

    {:ok,
     socket
     |> assign(:video, video)}
  end

  def get_video_details(id) do
    req = API.do_request()
    response = Req.get!(req, url: "/stream/#{id}")
    response.body["result"]
  end
end
