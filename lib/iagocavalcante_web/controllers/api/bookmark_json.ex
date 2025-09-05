defmodule IagocavalcanteWeb.API.BookmarkJSON do
  alias Iagocavalcante.Bookmarks.Bookmark

  @doc """
  Renders a list of bookmarks.
  """
  def index(%{bookmarks: bookmarks}) do
    %{
      data: for(bookmark <- bookmarks, do: data(bookmark)),
      meta: %{
        count: length(bookmarks)
      }
    }
  end

  @doc """
  Renders a single bookmark.
  """
  def show(%{bookmark: bookmark}) do
    %{data: data(bookmark)}
  end

  @doc """
  Renders bookmark statistics.
  """
  def stats(%{stats: stats}) do
    %{data: stats}
  end

  defp data(%Bookmark{} = bookmark) do
    %{
      id: bookmark.id,
      title: bookmark.title,
      url: bookmark.url,
      description: bookmark.description,
      tags: bookmark.tags || [],
      status: bookmark.status,
      archived: bookmark.archived,
      favorite: bookmark.favorite,
      read_time_minutes: bookmark.read_time_minutes,
      source: bookmark.source,
      domain: bookmark.domain,
      added_at: bookmark.added_at,
      inserted_at: bookmark.inserted_at,
      updated_at: bookmark.updated_at
    }
  end
end
