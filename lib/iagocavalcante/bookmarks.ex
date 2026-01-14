defmodule Iagocavalcante.Bookmarks do
  @moduledoc """
  The Bookmarks context for managing bookmarks from both CSV import and API.
  """

  import Ecto.Query, warn: false
  alias Iagocavalcante.Repo
  alias Iagocavalcante.Bookmarks.Bookmark

  # Legacy CSV support struct
  defstruct [:title, :url, :time_added, :tags, :status]

  @type csv_bookmark :: %__MODULE__{
          title: String.t(),
          url: String.t(),
          time_added: integer(),
          tags: list(String.t()),
          status: String.t()
        }

  ## Database CRUD operations

  @doc """
  Returns the list of bookmarks for a user.
  """
  def list_bookmarks(user_id, opts \\ []) do
    Bookmark
    |> where([b], b.user_id == ^user_id)
    |> maybe_filter_by_tags(opts[:tags])
    |> maybe_filter_by_status(opts[:status])
    |> maybe_filter_by_search(opts[:search])
    |> order_by([b], desc: b.added_at)
    |> Repo.all()
  end

  @doc """
  Gets a single bookmark by id for a user.
  """
  def get_bookmark!(user_id, id) do
    Bookmark
    |> where([b], b.user_id == ^user_id and b.id == ^id)
    |> Repo.one!()
  end

  @doc """
  Creates a bookmark for a user.
  """
  def create_bookmark(user_id, attrs \\ %{}) do
    attrs = Map.put(attrs, "user_id", user_id)

    %Bookmark{}
    |> Bookmark.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bookmark.
  """
  def update_bookmark(%Bookmark{} = bookmark, attrs) do
    bookmark
    |> Bookmark.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bookmark.
  """
  def delete_bookmark(%Bookmark{} = bookmark) do
    Repo.delete(bookmark)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bookmark changes.
  """
  def change_bookmark(%Bookmark{} = bookmark, attrs \\ %{}) do
    Bookmark.changeset(bookmark, attrs)
  end

  @doc """
  Archives a bookmark (soft delete).
  """
  def archive_bookmark(%Bookmark{} = bookmark) do
    update_bookmark(bookmark, %{archived: true, status: :archived})
  end

  @doc """
  Toggles favorite status of a bookmark.
  """
  def toggle_favorite(%Bookmark{} = bookmark) do
    update_bookmark(bookmark, %{favorite: !bookmark.favorite})
  end

  @doc """
  Marks a bookmark as read.
  """
  def mark_as_read(%Bookmark{} = bookmark) do
    update_bookmark(bookmark, %{status: :read})
  end

  @doc """
  Get bookmarks statistics for a user.
  """
  def get_stats(user_id) do
    total_query = from(b in Bookmark, where: b.user_id == ^user_id and not b.archived)

    read_query =
      from(b in Bookmark, where: b.user_id == ^user_id and b.status == :read and not b.archived)

    favorites_query =
      from(b in Bookmark, where: b.user_id == ^user_id and b.favorite == true and not b.archived)

    %{
      total: Repo.aggregate(total_query, :count),
      read: Repo.aggregate(read_query, :count),
      favorites: Repo.aggregate(favorites_query, :count),
      tags: get_user_tags(user_id)
    }
  end

  @doc """
  Get all tags used by a user.
  """
  def get_user_tags(user_id) do
    query =
      from(b in Bookmark,
        where: b.user_id == ^user_id and not b.archived,
        select: b.tags
      )

    query
    |> Repo.all()
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.reject(&(&1 == "" or is_nil(&1)))
    |> Enum.sort()
  end

  # Query helpers
  defp maybe_filter_by_tags(query, nil), do: query
  defp maybe_filter_by_tags(query, []), do: query

  defp maybe_filter_by_tags(query, tags) when is_list(tags) do
    where(query, [b], fragment("? && ?", b.tags, ^tags))
  end

  defp maybe_filter_by_status(query, nil), do: query

  defp maybe_filter_by_status(query, status) when is_atom(status) do
    where(query, [b], b.status == ^status)
  end

  defp maybe_filter_by_status(query, status) when is_binary(status) do
    # Convert string to atom for Ecto.Enum compatibility
    status_atom = String.to_existing_atom(status)
    where(query, [b], b.status == ^status_atom)
  rescue
    ArgumentError -> query
  end

  defp maybe_filter_by_search(query, nil), do: query
  defp maybe_filter_by_search(query, ""), do: query

  defp maybe_filter_by_search(query, search) when is_binary(search) do
    # Sanitize null bytes before using in query
    sanitized_search = String.replace(search, "\0", "")
    search_term = "%#{sanitized_search}%"

    where(
      query,
      [b],
      ilike(b.title, ^search_term) or
        ilike(b.url, ^search_term) or
        ilike(b.description, ^search_term)
    )
  end

  ## Legacy CSV support functions

  alias Iagocavalcante.Bookmarks.Cache

  @doc """
  Load all bookmarks from cache (originally from CSV file).

  Uses ETS cache for fast access. Call `invalidate_cache/0` to refresh.
  """
  def all_bookmarks do
    Cache.all_bookmarks()
  end

  @doc """
  Get bookmarks grouped by tags from cache.
  """
  def bookmarks_by_tag do
    Cache.bookmarks_by_tag()
  end

  @doc """
  Invalidate the bookmarks cache and reload from CSV.
  """
  def invalidate_cache do
    Cache.invalidate()
  end

  @doc """
  Get all unique tags sorted by frequency.
  """
  def all_tags do
    bookmarks_by_tag()
    |> Enum.map(fn {tag, bookmarks} -> {tag, length(bookmarks)} end)
  end

  @doc """
  Get bookmarks for a specific tag.
  """
  def bookmarks_for_tag(tag) do
    bookmarks_by_tag()
    |> Map.new()
    |> Map.get(tag, [])
    |> Enum.sort_by(&(-&1.time_added))
  end

  @doc """
  Get featured tags (top tags with most bookmarks).
  """
  def featured_tags(limit \\ 10) do
    all_tags()
    |> Enum.take(limit)
  end

  @doc """
  Convert Unix timestamp to readable date
  """
  def format_date(timestamp) when is_integer(timestamp) do
    timestamp
    |> DateTime.from_unix!()
    |> DateTime.to_date()
    |> Date.to_string()
  end

  @doc """
  Get domain from URL for display
  """
  def get_domain(url) do
    case URI.parse(url) do
      %URI{host: host} when is_binary(host) -> host
      _ -> ""
    end
  end

  @doc """
  Get initials for a tag (for display purposes)
  """
  def tag_initials(tag) do
    tag
    |> String.split(["-", "_", " "])
    |> Enum.map(&String.first/1)
    |> Enum.take(2)
    |> Enum.join("")
    |> String.upcase()
  end

  @doc """
  Get a color for a tag based on its hash
  """
  def tag_color(tag) do
    colors = [
      "bg-red-500",
      "bg-green-500",
      "bg-blue-500",
      "bg-yellow-500",
      "bg-purple-500",
      "bg-pink-500",
      "bg-indigo-500",
      "bg-orange-500",
      "bg-teal-500",
      "bg-cyan-500",
      "bg-emerald-500",
      "bg-rose-500"
    ]

    hash = :erlang.phash2(tag, length(colors))
    Enum.at(colors, hash)
  end
end
