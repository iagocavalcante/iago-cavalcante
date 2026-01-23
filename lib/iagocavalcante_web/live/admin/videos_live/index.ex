defmodule IagocavalcanteWeb.Admin.VideosLive.Index do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Clients.Cloudflare.API.Stream
  alias Iagocavalcante.Blog

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    # Iron Law: NO database/API queries in mount - it's called twice (HTTP + WebSocket)
    {:ok,
     socket
     |> assign(:videos, [])
     |> assign(:loading, true)
     |> assign(:upload_phase, :idle)
     |> assign(:upload_error, nil)
     |> assign(:upload_progress, nil)
     |> assign(:video_name, nil)
     |> assign(:current_page, :videos)
     |> assign(:pending_comments_count, 0)
     |> allow_upload(:video,
       accept: ~w(.mp4 .avi .mov),
       max_file_size: 1024 * 1024 * 1024,
       progress: &handle_progress/3
     )}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    # Data loading happens here - runs once after WebSocket connection
    socket =
      socket
      |> start_async(:load_videos, fn -> Stream.list_videos() end)
      |> start_async(:load_pending_comments, fn -> Blog.list_pending_comments() |> length() end)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_async(:load_videos, {:ok, {:ok, videos}}, socket) do
    formatted_videos = Enum.map(videos, &format_video/1)
    {:noreply, assign(socket, videos: formatted_videos, loading: false)}
  end

  def handle_async(:load_videos, {:ok, {:error, message}}, socket) do
    Logger.error("Failed to load videos: #{inspect(message)}")
    {:noreply, assign(socket, upload_error: message, loading: false)}
  end

  def handle_async(:load_videos, {:exit, reason}, socket) do
    Logger.error("Video loading task crashed: #{inspect(reason)}")
    {:noreply, assign(socket, upload_error: "Failed to load videos", loading: false)}
  end

  def handle_async(:load_pending_comments, {:ok, count}, socket) do
    {:noreply, assign(socket, pending_comments_count: count)}
  end

  def handle_async(:load_pending_comments, {:exit, reason}, socket) do
    Logger.warning("Failed to load pending comments count: #{inspect(reason)}")
    {:noreply, socket}
  end

  defp handle_progress(:video, entry, socket) do
    if entry.done? do
      {:noreply, assign(socket, :upload_phase, :processing)}
    else
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"video_name" => video_name} = _params, socket) do
    user_email = socket.assigns.current_user.email
    liveview_pid = self()

    # Consume uploaded files and get paths
    uploaded_files =
      consume_uploaded_entries(socket, :video, fn %{path: path}, entry ->
        # Copy file to a temp location since the original will be deleted
        temp_path =
          Path.join(
            System.tmp_dir!(),
            "video_#{entry.ref}_#{:erlang.unique_integer([:positive])}"
          )

        File.cp!(path, temp_path)
        {:ok, %{path: temp_path, entry: entry}}
      end)

    # Update phase to uploading_to_cloudflare
    socket = assign(socket, upload_phase: :uploading_to_cloudflare, upload_progress: nil)

    # Start async upload to Cloudflare with progress callback
    Task.Supervisor.start_child(Iagocavalcante.TaskSupervisor, fn ->
      results =
        Enum.map(uploaded_files, fn %{path: path, entry: entry} ->
          progress_callback = fn bytes_sent, total ->
            percentage = if total > 0, do: round(bytes_sent / total * 100), else: 0
            send(liveview_pid, {:cloudflare_upload_progress, percentage, bytes_sent, total})
          end

          result =
            case Stream.upload_video(path, user_email, video_name, entry,
                   progress_callback: progress_callback
                 ) do
              {:ok, video} ->
                Stream.enable_download(video["uid"])
                {:ok, format_video(video)}

              {:error, reason} ->
                Logger.error("Video upload failed: #{inspect(reason)}")
                {:error, reason}
            end

          # Clean up temp file
          File.rm(path)
          result
        end)

      send(liveview_pid, {:upload_complete, results})
    end)

    {:noreply, socket}
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

  @impl Phoenix.LiveView
  def handle_info({:cloudflare_upload_progress, percentage, bytes_sent, total_bytes}, socket) do
    {:noreply,
     assign(socket, :upload_progress, %{
       percentage: percentage,
       bytes_sent: bytes_sent,
       total_bytes: total_bytes
     })}
  end

  @impl Phoenix.LiveView
  def handle_info({:upload_complete, results}, socket) do
    {successes, failures} =
      Enum.split_with(results, fn
        {:ok, _} -> true
        {:error, _} -> false
      end)

    videos = Enum.map(successes, fn {:ok, video} -> video end)

    socket =
      socket
      |> assign(:upload_phase, :idle)
      |> assign(:upload_progress, nil)
      |> update(:videos, fn existing -> videos ++ existing end)

    socket =
      case failures do
        [] ->
          put_flash(socket, :info, "Video uploaded successfully!")

        errors ->
          error_msg =
            Enum.map(errors, fn {:error, reason} -> inspect(reason) end) |> Enum.join(", ")

          put_flash(socket, :error, "Some uploads failed: #{error_msg}")
      end

    {:noreply, socket}
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

  @doc """
  Formats bytes into a human-readable string (KB, MB, GB).
  """
  def format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_073_741_824 -> "#{Float.round(bytes / 1_073_741_824, 2)} GB"
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 2)} MB"
      bytes >= 1_024 -> "#{Float.round(bytes / 1_024, 2)} KB"
      true -> "#{bytes} B"
    end
  end

  def format_bytes(_), do: "0 B"

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
