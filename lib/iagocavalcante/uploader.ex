defmodule Iagocavalcante.Uploader do
  def upload(folder, path, opts \\ []), do: do_upload(folder, path, opts)

  defp do_upload(_folder, "", _opts), do: {:ok, nil}

  defp do_upload(folder, file_params, opts) do
    filename =
      file_params.filename
      |> normalize_filename()

    case File.read(file_params.path) do
      {:ok, binary} ->
        perform_upload(
          filename,
          folder,
          binary,
          Keyword.merge(opts, content_type: file_params.content_type)
        )

      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_presigned_url!(nil), do: nil

  def get_presigned_url!(path) do
    {_, result} = get_presigned_url(path)
    result
  end

  def get_presigned_url(nil), do: {:error, nil}

  def get_presigned_url(path) do
    ExAws.S3.presigned_url(s3(), :get, Keyword.get(settings(), :bucket), path, virtual_host: true)
  end

  def get_url(path) do
    "https://" <> host() <> "/" <> path
  end

  defp perform_upload(filename, folder, binary, opts) do
    case put_to_s3(filename, folder, binary, opts) do
      {:ok, _} -> {:ok, "#{folder}/#{filename}"}
      error -> {:error, error}
    end
  end

  defp put_to_s3(filename, folder, binary, opts) do
    config = s3(host: host())

    ExAws.S3.put_object(folder, filename, binary, opts)
    |> ExAws.request(config)
  end

  defp s3(extra \\ []) do
    ExAws.Config.new(:s3, Keyword.merge(settings(), extra))
  end

  defp settings do
    [
      access_key_id: Application.fetch_env!(:iagocavalcante, :aws_access_key),
      secret_access_key: Application.fetch_env!(:iagocavalcante, :secret_access_key),
      region: Application.fetch_env!(:iagocavalcante, :region),
      bucket: Application.fetch_env!(:iagocavalcante, :bucket_name)
    ]
  end

  defp host do
    bucket = settings() |> Keyword.get(:bucket)

    "#{bucket}.s3.amazonaws.com"
  end

  defp normalize_filename(filename) do
    unique_identifier = :crypto.strong_rand_bytes(8) |> Base.encode16()
    "#{unique_identifier}-#{filename}"
  end
end
