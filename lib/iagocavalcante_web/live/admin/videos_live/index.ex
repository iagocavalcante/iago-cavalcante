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
          |> assign(:upload_phase, :idle)
          |> assign(:upload_error, nil)
          |> assign(:video_name, nil)
          |> assign(:current_page, :videos)
          |> assign(:pending_comments_count, pending_comments_count)
          |> allow_upload(:video,
            accept: ~w(.mp4 .avi .mov),
            max_file_size: 1024 * 1024 * 1024,
            progress: &handle_progress/3
          )
        }

      {:error, message} ->
        {:ok,
         socket
         |> assign(:upload_error, message)
         |> assign(:upload_phase, :idle)
         |> assign(:current_page, :videos)
         |> assign(:pending_comments_count, pending_comments_count)}
    end
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

    # Start async upload to Cloudflare
    Task.Supervisor.start_child(Iagocavalcante.TaskSupervisor, fn ->
      results =
        Enum.map(uploaded_files, fn %{path: path, entry: entry} ->
          result =
            case Stream.upload_video(path, user_email, video_name, entry) do
              {:ok, video} ->
                Stream.enable_download(video["uid"])
                {:ok, format_video(video)}

              {:error, reason} ->
                {:error, reason}
            end

          # Clean up temp file
          File.rm(path)
          result
        end)

      send(liveview_pid, {:upload_complete, results})
    end)

    {:noreply, assign(socket, :upload_phase, :processing)}
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

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
