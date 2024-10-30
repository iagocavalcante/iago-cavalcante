defmodule Iagocavalcante.Clients.Cloudflare.API.Stream do
  alias Iagocavalcante.Clients.Cloudflare.API

  def list_videos(account_id \\ nil) do
    API.do_request(account_id)
    |> Req.get!(url: "/stream")
    |> then(fn response ->
      case response do
        %{status: 200, body: body} ->
          {:ok, body["result"]}

        error ->
          IO.inspect(error, label: "Erro ao listar vídeos")
          {:error, "Failed to fetch videos"}
      end
    end)
  end

  def upload_video(file_path, user_email, video_title, entry, account_id \\ nil) do
    filename = Path.basename(file_path)
    {:ok, file_contents} = File.read(file_path)

    multipart =
      Multipart.new()
      |> Multipart.add_part(
        Multipart.Part.file_content_field(filename, file_contents, :file, filename: filename)
      )

    content_length = Multipart.content_length(multipart)
    content_type = Multipart.content_type(multipart, "multipart/form-data")

    result =
      API.do_request(account_id)
      |> Req.post!(
        url: "/stream",
        headers: [
          {"Content-Type", content_type},
          {"Content-Length", to_string(content_length)}
        ],
        body: Multipart.body_stream(multipart)
      )

    case result do
      %{status: 200, body: %{"result" => video}} ->
        update_response =
          API.do_request(account_id)
          |> Req.post!(
            url: "/stream/#{video["uid"]}",
            json: %{
              meta: %{name: entry.client_name},
              publicDetails: %{title: video_title},
              creator: user_email
            }
          )

        case update_response do
          %{status: 200, body: %{"result" => updated_video}} ->
            {:ok, updated_video}

          error ->
            IO.inspect(error, label: "Erro ao atualizar metadados")
            {:ok, video}
        end

      error ->
        IO.inspect(error, label: "Erro ao fazer upload")
        {:error, "Failed to upload video"}
    end
  end

  def delete_video(video_id, account_id \\ nil) do
    API.do_request(account_id)
    |> Req.delete!(url: "/stream/#{video_id}")
    |> then(fn response ->
      case response do
        %{status: 200} -> {:ok, "Video deleted successfully"}
        _ -> {:error, "Failed to delete video"}
      end
    end)
  end

  def enable_download(video_id, account_id \\ nil) do
    API.do_request(account_id)
    |> Req.post!(url: "/stream/#{video_id}/downloads")
    |> then(fn response ->
      case response do
        %{status: 200} -> {:ok, response}
        _ -> {:error, "Failed to enable video to download"}
      end
    end)
  end
end
