defmodule Iagocavalcante.Clients.Cloudflare.API.Stream do
  @moduledoc """
  Cloudflare Stream API client with proper error handling, logging, and retries.
  """

  alias Iagocavalcante.Clients.Cloudflare.API
  alias Iagocavalcante.Clients.Cloudflare.StreamingUpload

  require Logger

  # Configuration
  # 30 seconds for receive timeout
  @default_timeout 30_000

  @doc """
  Lists all videos from Cloudflare Stream.

  ## Returns

    * `{:ok, videos}` - List of video objects
    * `{:error, reason}` - Error with reason string
  """
  def list_videos(account_id \\ nil) do
    request = build_request(account_id)

    case Req.get(request, url: "/stream") do
      {:ok, %{status: 200, body: %{"result" => videos}}} ->
        {:ok, videos}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to list videos: HTTP #{status}, body: #{inspect(body)}")
        {:error, "Failed to fetch videos (HTTP #{status})"}

      {:error, %Req.TransportError{reason: reason}} ->
        Logger.error("Network error listing videos: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}

      {:error, reason} ->
        Logger.error("Error listing videos: #{inspect(reason)}")
        {:error, "Failed to fetch videos"}
    end
  end

  @doc """
  Uploads a video to Cloudflare Stream.

  Delegates to StreamingUpload for chunked streaming with progress tracking.

  ## Options

    * `:progress_callback` - Function called with (bytes_sent, total_bytes) during upload
    * `:timeout` - Upload timeout in milliseconds
    * `:account_id` - Cloudflare account ID (overrides default)

  ## Returns

    * `{:ok, video}` - Video metadata from Cloudflare
    * `{:error, reason}` - Error with reason string
  """
  def upload_video(file_path, user_email, video_title, entry, opts \\ []) do
    StreamingUpload.upload_video(file_path, user_email, video_title, entry, opts)
  end

  @doc """
  Deletes a video from Cloudflare Stream.

  ## Returns

    * `{:ok, message}` - Success message
    * `{:error, reason}` - Error with reason string
  """
  def delete_video(video_id, account_id \\ nil) do
    request = build_request(account_id)

    case Req.delete(request, url: "/stream/#{video_id}") do
      {:ok, %{status: 200}} ->
        Logger.info("Video deleted successfully: #{video_id}")
        {:ok, "Video deleted successfully"}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to delete video #{video_id}: HTTP #{status}, body: #{inspect(body)}")
        {:error, "Failed to delete video (HTTP #{status})"}

      {:error, %Req.TransportError{reason: reason}} ->
        Logger.error("Network error deleting video #{video_id}: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}

      {:error, reason} ->
        Logger.error("Error deleting video #{video_id}: #{inspect(reason)}")
        {:error, "Failed to delete video"}
    end
  end

  @doc """
  Enables download for a video on Cloudflare Stream.

  ## Returns

    * `{:ok, response}` - Success response
    * `{:error, reason}` - Error with reason string
  """
  def enable_download(video_id, account_id \\ nil) do
    request = build_request(account_id)

    case Req.post(request, url: "/stream/#{video_id}/downloads") do
      {:ok, %{status: 200} = response} ->
        Logger.info("Downloads enabled for video: #{video_id}")
        {:ok, response}

      {:ok, %{status: status, body: body}} ->
        Logger.warning(
          "Failed to enable downloads for #{video_id}: HTTP #{status}, body: #{inspect(body)}"
        )

        {:error, "Failed to enable video download (HTTP #{status})"}

      {:error, %Req.TransportError{reason: reason}} ->
        Logger.warning("Network error enabling downloads for #{video_id}: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}

      {:error, reason} ->
        Logger.warning("Error enabling downloads for #{video_id}: #{inspect(reason)}")
        {:error, "Failed to enable video download"}
    end
  end

  # Build a request with timeout
  defp build_request(account_id) do
    API.do_request(account_id)
    |> Req.merge(receive_timeout: @default_timeout)
  end
end
