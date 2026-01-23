defmodule Iagocavalcante.Clients.Cloudflare.StreamingUpload do
  @moduledoc """
  Handles streaming uploads to Cloudflare Stream with:
  - Chunked file streaming (avoids loading large files into memory)
  - Progress callbacks for real-time UI updates
  - Retry logic with exponential backoff
  - Configurable timeouts
  """

  require Logger

  # Configuration defaults
  # 5MB chunks
  @chunk_size 5 * 1024 * 1024
  # 30 seconds for API calls
  @default_timeout 30_000
  # 10 minutes for uploads
  @upload_timeout 600_000
  # 10 seconds
  @connect_timeout 10_000
  # Exponential backoff
  @retry_delays [1_000, 2_000, 4_000, 8_000, 16_000]

  @doc """
  Uploads a video to Cloudflare Stream with streaming and progress tracking.

  ## Options

    * `:progress_callback` - Function called with (bytes_sent, total_bytes) during upload
    * `:timeout` - Upload timeout in milliseconds (default: #{@upload_timeout})
    * `:account_id` - Cloudflare account ID (default: from config)
    * `:max_retries` - Maximum retry attempts (default: #{length(@retry_delays)})

  ## Returns

    * `{:ok, video_data}` - Video metadata from Cloudflare
    * `{:error, reason}` - Error with reason string

  ## Examples

      StreamingUpload.upload_video(
        "/path/to/video.mp4",
        "user@example.com",
        "My Video",
        entry,
        progress_callback: fn bytes, total -> IO.puts("\#{bytes}/\#{total}") end
      )
  """
  def upload_video(file_path, user_email, video_title, entry, opts \\ []) do
    progress_callback = Keyword.get(opts, :progress_callback, fn _, _ -> :ok end)
    timeout = Keyword.get(opts, :timeout, @upload_timeout)
    account_id = Keyword.get(opts, :account_id)
    max_retries = Keyword.get(opts, :max_retries, length(@retry_delays))

    with {:ok, file_stat} <- get_file_stat(file_path),
         {:ok, video} <-
           upload_with_retry(
             file_path,
             file_stat.size,
             progress_callback,
             timeout,
             account_id,
             max_retries
           ),
         {:ok, updated_video} <-
           update_video_metadata(video, user_email, video_title, entry, account_id) do
      {:ok, updated_video}
    end
  end

  defp get_file_stat(file_path) do
    case File.stat(file_path) do
      {:ok, stat} ->
        {:ok, stat}

      {:error, reason} ->
        Logger.error("Failed to stat file #{file_path}: #{inspect(reason)}")
        {:error, "Failed to read file: #{reason}"}
    end
  end

  defp upload_with_retry(
         file_path,
         total_bytes,
         progress_callback,
         timeout,
         account_id,
         max_retries
       ) do
    retry_delays = Enum.take(@retry_delays, max_retries)

    do_upload_with_retry(
      file_path,
      total_bytes,
      progress_callback,
      timeout,
      account_id,
      retry_delays,
      0
    )
  end

  defp do_upload_with_retry(
         file_path,
         total_bytes,
         progress_callback,
         timeout,
         account_id,
         retry_delays,
         attempt
       ) do
    case do_streaming_upload(file_path, total_bytes, progress_callback, timeout, account_id) do
      {:ok, video} ->
        {:ok, video}

      {:error, reason} = error ->
        if should_retry?(reason) and attempt < length(retry_delays) do
          delay = Enum.at(retry_delays, attempt)

          Logger.warning(
            "Upload failed (attempt #{attempt + 1}), retrying in #{delay}ms: #{inspect(reason)}"
          )

          Process.sleep(delay)

          do_upload_with_retry(
            file_path,
            total_bytes,
            progress_callback,
            timeout,
            account_id,
            retry_delays,
            attempt + 1
          )
        else
          Logger.error("Upload failed after #{attempt + 1} attempts: #{inspect(reason)}")
          error
        end
    end
  end

  defp should_retry?(reason) do
    # Retry on transient errors (network issues, timeouts, 5xx errors)
    cond do
      is_binary(reason) and String.contains?(reason, ["timeout", "connection", "network"]) -> true
      # 5xx errors
      is_binary(reason) and String.contains?(reason, "5") -> true
      reason == :timeout -> true
      reason == :closed -> true
      true -> false
    end
  end

  defp do_streaming_upload(file_path, total_bytes, progress_callback, timeout, account_id) do
    filename = Path.basename(file_path)

    # Create streaming body with progress tracking
    body_stream = create_streaming_body(file_path, total_bytes, progress_callback)

    # Build multipart manually for streaming
    boundary = generate_boundary()
    content_type = "multipart/form-data; boundary=#{boundary}"

    # Calculate content length including multipart headers
    {prefix, suffix} = multipart_wrapper(boundary, filename)
    content_length = byte_size(prefix) + total_bytes + byte_size(suffix)

    # Create the full streaming body
    full_body =
      Stream.concat([
        [prefix],
        body_stream,
        [suffix]
      ])

    request = build_request(account_id)

    result =
      request
      |> Req.post(
        url: "/stream",
        headers: [
          {"Content-Type", content_type},
          {"Content-Length", to_string(content_length)}
        ],
        body: full_body,
        receive_timeout: timeout,
        connect_timeout: @connect_timeout
      )

    case result do
      {:ok, %{status: 200, body: %{"result" => video}}} ->
        Logger.info("Video uploaded successfully: #{video["uid"]}")
        {:ok, video}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Upload failed with status #{status}: #{inspect(body)}")
        {:error, "Upload failed: HTTP #{status}"}

      {:error, %Req.TransportError{reason: reason}} ->
        Logger.error("Transport error during upload: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}

      {:error, reason} ->
        Logger.error("Upload error: #{inspect(reason)}")
        {:error, "Upload failed: #{inspect(reason)}"}
    end
  end

  defp create_streaming_body(file_path, total_bytes, progress_callback) do
    # Stream the file in chunks to avoid loading into memory
    file_path
    |> File.stream!([], @chunk_size)
    |> Stream.transform(0, fn chunk, bytes_sent ->
      new_bytes_sent = bytes_sent + byte_size(chunk)
      progress_callback.(new_bytes_sent, total_bytes)
      {[chunk], new_bytes_sent}
    end)
  end

  defp generate_boundary do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  defp multipart_wrapper(boundary, filename) do
    prefix = """
    --#{boundary}\r
    Content-Disposition: form-data; name="file"; filename="#{filename}"\r
    Content-Type: application/octet-stream\r
    \r
    """

    suffix = "\r\n--#{boundary}--\r\n"

    {prefix, suffix}
  end

  defp update_video_metadata(video, user_email, video_title, entry, account_id) do
    request = build_request(account_id)

    result =
      request
      |> Req.post(
        url: "/stream/#{video["uid"]}",
        json: %{
          meta: %{name: entry.client_name},
          publicDetails: %{title: video_title},
          creator: user_email
        },
        receive_timeout: @default_timeout,
        connect_timeout: @connect_timeout
      )

    case result do
      {:ok, %{status: 200, body: %{"result" => updated_video}}} ->
        Logger.info("Video metadata updated: #{updated_video["uid"]}")
        {:ok, updated_video}

      {:ok, %{status: status, body: body}} ->
        Logger.warning("Failed to update metadata (status #{status}): #{inspect(body)}")
        # Non-fatal - return original video
        {:ok, video}

      {:error, reason} ->
        Logger.warning("Failed to update metadata: #{inspect(reason)}")
        # Non-fatal - return original video
        {:ok, video}
    end
  end

  defp build_request(account_id) do
    auth = auth()
    account = account_id || auth.account_id

    base_url =
      case account do
        nil -> auth.base_url
        id -> "#{auth.base_url}/client/v4/accounts/#{id}"
      end

    Req.new(
      base_url: base_url,
      headers: %{
        "Authorization" => "Bearer #{auth.token}"
      },
      receive_timeout: @default_timeout,
      connect_timeout: @connect_timeout
    )
  end

  defp auth do
    %{
      base_url: Application.get_env(:iagocavalcante, :cloudflare_base_url),
      token: Application.get_env(:iagocavalcante, :cloudflare_api_token),
      account_id: Application.get_env(:iagocavalcante, :cloudflare_account_id)
    }
  end
end
