defmodule IagocavalcanteWeb.API.BookmarkController do
  use IagocavalcanteWeb, :controller

  alias Iagocavalcante.Bookmarks
  alias Iagocavalcante.Bookmarks.Bookmark

  action_fallback IagocavalcanteWeb.FallbackController

  @doc """
  GET /api/bookmarks
  List all bookmarks for the authenticated user with optional filtering
  """
  def index(conn, params) do
    user = conn.assigns[:current_user]

    opts = [
      tags: parse_tags(params["tags"]),
      status: params["status"],
      search: params["search"]
    ]

    bookmarks = Bookmarks.list_bookmarks(user.id, opts)
    render(conn, :index, bookmarks: bookmarks)
  end

  @doc """
  GET /api/bookmarks/stats
  Get bookmark statistics for the authenticated user
  """
  def stats(conn, _params) do
    user = conn.assigns[:current_user]
    stats = Bookmarks.get_stats(user.id)
    render(conn, :stats, stats: stats)
  end

  @doc """
  POST /api/bookmarks
  Create a new bookmark
  """
  def create(conn, %{"bookmark" => bookmark_params}) do
    user = conn.assigns[:current_user]

    # Extract metadata from URL if not provided
    bookmark_params = maybe_extract_metadata(bookmark_params)

    with {:ok, %Bookmark{} = bookmark} <- Bookmarks.create_bookmark(user.id, bookmark_params) do
      conn
      |> put_status(:created)
      |> render(:show, bookmark: bookmark)
    end
  end

  @doc """
  GET /api/bookmarks/:id
  Get a specific bookmark
  """
  def show(conn, %{"id" => id}) do
    user = conn.assigns[:current_user]
    bookmark = Bookmarks.get_bookmark!(user.id, id)
    render(conn, :show, bookmark: bookmark)
  end

  @doc """
  PUT /api/bookmarks/:id
  Update a bookmark
  """
  def update(conn, %{"id" => id, "bookmark" => bookmark_params}) do
    user = conn.assigns[:current_user]
    bookmark = Bookmarks.get_bookmark!(user.id, id)

    with {:ok, %Bookmark{} = bookmark} <- Bookmarks.update_bookmark(bookmark, bookmark_params) do
      render(conn, :show, bookmark: bookmark)
    end
  end

  @doc """
  DELETE /api/bookmarks/:id
  Delete a bookmark
  """
  def delete(conn, %{"id" => id}) do
    user = conn.assigns[:current_user]
    bookmark = Bookmarks.get_bookmark!(user.id, id)

    with {:ok, %Bookmark{}} <- Bookmarks.delete_bookmark(bookmark) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc """
  PATCH /api/bookmarks/:id/archive
  Archive a bookmark
  """
  def archive(conn, %{"id" => id}) do
    user = conn.assigns[:current_user]
    bookmark = Bookmarks.get_bookmark!(user.id, id)

    with {:ok, %Bookmark{} = bookmark} <- Bookmarks.archive_bookmark(bookmark) do
      render(conn, :show, bookmark: bookmark)
    end
  end

  @doc """
  PATCH /api/bookmarks/:id/favorite
  Toggle favorite status of a bookmark
  """
  def toggle_favorite(conn, %{"id" => id}) do
    user = conn.assigns[:current_user]
    bookmark = Bookmarks.get_bookmark!(user.id, id)

    with {:ok, %Bookmark{} = bookmark} <- Bookmarks.toggle_favorite(bookmark) do
      render(conn, :show, bookmark: bookmark)
    end
  end

  @doc """
  PATCH /api/bookmarks/:id/read
  Mark a bookmark as read
  """
  def mark_as_read(conn, %{"id" => id}) do
    user = conn.assigns[:current_user]
    bookmark = Bookmarks.get_bookmark!(user.id, id)

    with {:ok, %Bookmark{} = bookmark} <- Bookmarks.mark_as_read(bookmark) do
      render(conn, :show, bookmark: bookmark)
    end
  end

  # Helper functions

  defp parse_tags(nil), do: nil
  defp parse_tags(""), do: []
  defp parse_tags(tags) when is_binary(tags) do
    tags
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
  defp parse_tags(tags) when is_list(tags), do: tags

  defp maybe_extract_metadata(params) do
    case params["url"] do
      nil -> params
      url ->
        # In a real implementation, you'd fetch the page and extract title/description
        # For now, we'll use the URL as title if no title is provided
        params
        |> Map.put_new("title", extract_title_from_url(url))
        |> Map.put_new("description", "")
    end
  end

  defp extract_title_from_url(url) do
    case URI.parse(url) do
      %URI{host: host, path: path} when is_binary(host) ->
        case path do
          nil -> host
          "/" -> host
          path -> "#{host}#{path}"
        end
      _ -> url
    end
  end
end
