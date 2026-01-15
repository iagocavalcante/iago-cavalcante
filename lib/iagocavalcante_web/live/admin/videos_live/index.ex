defmodule IagocavalcanteWeb.Admin.VideosLive.Index do
  use IagocavalcanteWeb, :live_view
  alias Iagocavalcante.Clients.Cloudflare.API.Stream
  alias Iagocavalcante.Blog

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    pending_comments_count = Blog.list_pending_comments() |> length()

    case Stream.list_videos() do
      {:ok, videos} ->
        formatted_videos = Enum.map(videos, &format_video/1)

        {
          :ok,
          socket
          |> assign(:videos, formatted_videos)
          |> assign(:uploading, false)
          |> assign(:error, nil)
          |> assign(:video_name, nil)
          |> assign(:current_page, :videos)
          |> assign(:pending_comments_count, pending_comments_count)
          |> allow_upload(:video,
            accept: ~w(.mp4 .avi .mov),
            max_file_size: 1024 * 1024 * 1024
          )
        }

      {:error, message} ->
        {:ok,
         socket
         |> assign(:error, message)
         |> assign(:current_page, :videos)
         |> assign(:pending_comments_count, pending_comments_count)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"video_name" => video_name} = _params, socket) do
    user_email = socket.assigns.current_user.email

    socket = assign(socket, :uploading, true)

    video =
      consume_uploaded_entries(socket, :video, fn %{path: path}, entry ->
        case Stream.upload_video(path, user_email, video_name, entry) do
          {:ok, video} ->
            Stream.enable_download(video["uid"])
            {:ok, video}

          {:error, reason} ->
            {:postpone, reason}
        end
      end)

    {:noreply,
     socket
     |> update(:videos, &[video | &1])
     |> assign(:uploading, false)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :video, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete-video", %{"id" => video_id}, socket) do
    case Stream.delete_video(video_id) do
      {:ok, _} ->
        videos = Enum.reject(socket.assigns.videos, &(&1["id"] == video_id))
        {:noreply, assign(socket, :videos, videos)}

      {:error, message} ->
        {:noreply, assign(socket, :error, message)}
    end
  end

  def handle_event("download-video", %{"id" => video_uid}, socket) do
    url = get_download_url(video_uid)

    {:noreply, redirect(socket, url)}
  end

  def get_download_url(video_uid) do
    "https://customer-4db4ju1s3max6u8j.cloudflarestream.com/#{video_uid}/downloads/default.mp4?filename=MY_VIDEO.mp4"
  end

  defp format_video(video) do
    # Garante que video é um mapa com string keys
    video = for {key, val} <- video, into: %{}, do: {to_string(key), val}

    %{
      "id" => video["uid"],
      "name" => get_in(video, ["publicDetails", "title"]) || "Untitled",
      "duration" => video["duration"] || 0,
      "thumbnail" => video["thumbnail"] || nil,
      "preview" => video["preview"] || nil,
      "size" => video["size"] || 0,
      "resolution" => %{
        "width" => get_in(video, ["input", "width"]) || 0,
        "height" => get_in(video, ["input", "height"]) || 0
      },
      "status" => get_in(video, ["status", "state"]) || "processing",
      "created_at" => video["created"],
      "requireSignedURLs" => video["requireSignedURLs"] || false,
      "playback" => %{
        "hls" => get_in(video, ["playback", "hls"]) || nil,
        "dash" => get_in(video, ["playback", "dash"]) || nil
      }
    }
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
