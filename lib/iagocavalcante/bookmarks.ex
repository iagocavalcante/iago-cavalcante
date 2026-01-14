defmodule Iagocavalcante.Bookmarks do
  @moduledoc """
  The Bookmarks context for managing bookmarks from both CSV import and API.

  For presentation/formatting helpers, see `Iagocavalcante.Bookmarks.Formatter`.
  """

  import Ecto.Query, warn: false
  alias Iagocavalcante.Repo
  alias Iagocavalcante.Bookmarks.Bookmark
  alias Iagocavalcante.Bookmarks.Formatter

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

  Optimized to use a single query with conditional aggregation instead of
  4 separate queries.
  """
  def get_stats(user_id) do
    # Single query with conditional counts using filter
    {total, read, favorites} =
      from(b in Bookmark,
        where: b.user_id == ^user_id and not b.archived,
        select: {
          count(b.id),
          filter(count(b.id), b.status == :read),
          filter(count(b.id), b.favorite == true)
        }
      )
      |> Repo.one() || {0, 0, 0}

    %{
      total: total,
      read: read,
      favorites: favorites,
      tags: list_user_tags(user_id)
    }
  end

  @doc """
  Get all unique tags used by a user.

  Optimized to use PostgreSQL's unnest for efficient tag extraction
  instead of loading all tag arrays into memory.
  """
  def list_user_tags(user_id) do
    from(b in Bookmark,
      where: b.user_id == ^user_id and not b.archived,
      select: fragment("DISTINCT unnest(?)", b.tags),
      order_by: fragment("1")
    )
    |> Repo.all()
    |> Enum.reject(&(&1 == "" or is_nil(&1)))
  end

  @doc """
  Get all tags used by a user.

  Deprecated: Use `list_user_tags/1` instead for better naming consistency.
  """
  def get_user_tags(user_id), do: list_user_tags(user_id)

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

  # Presentation helpers - delegated to Formatter module for separation of concerns
  # Kept here for backwards compatibility

  @doc """
  Convert Unix timestamp to readable date.
  See `Iagocavalcante.Bookmarks.Formatter.format_date/1`.
  """
  defdelegate format_date(timestamp), to: Formatter

  @doc """
  Get domain from URL for display.
  See `Iagocavalcante.Bookmarks.Formatter.get_domain/1`.
  """
  defdelegate get_domain(url), to: Formatter

  @doc """
  Get initials for a tag (for display purposes).
  See `Iagocavalcante.Bookmarks.Formatter.tag_initials/1`.
  """
  defdelegate tag_initials(tag), to: Formatter

  @doc """
  Get a color for a tag based on its hash.
  See `Iagocavalcante.Bookmarks.Formatter.tag_color/1`.
  """
  defdelegate tag_color(tag), to: Formatter
end
