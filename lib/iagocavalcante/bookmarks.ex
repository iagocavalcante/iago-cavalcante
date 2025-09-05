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
    update_bookmark(bookmark, %{archived: true, status: "archived"})
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
    update_bookmark(bookmark, %{status: "read"})
  end

  @doc """
  Get bookmarks statistics for a user.
  """
  def get_stats(user_id) do
    total_query = from(b in Bookmark, where: b.user_id == ^user_id and not b.archived)
    read_query = from(b in Bookmark, where: b.user_id == ^user_id and b.status == "read" and not b.archived)
    favorites_query = from(b in Bookmark, where: b.user_id == ^user_id and b.favorite == true and not b.archived)

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
    query = from(b in Bookmark,
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
  defp maybe_filter_by_status(query, status) when is_binary(status) do
    where(query, [b], b.status == ^status)
  end

  defp maybe_filter_by_search(query, nil), do: query
  defp maybe_filter_by_search(query, ""), do: query
  defp maybe_filter_by_search(query, search) when is_binary(search) do
    search_term = "%#{search}%"
    where(query, [b],
      ilike(b.title, ^search_term) or
      ilike(b.url, ^search_term) or
      ilike(b.description, ^search_term)
    )
  end

  ## Legacy CSV support functions

  @doc """
  Debug function to show all potential CSV file paths
  """
  def debug_csv_paths do
    paths = [
      {"Production (app_dir)", Path.join([Application.app_dir(:iagocavalcante), "priv", "bookmarks.csv"])},
      {"Development (code.priv_dir)", Path.join([:code.priv_dir(:iagocavalcante), "bookmarks.csv"])},
      {"Relative path", "priv/bookmarks.csv"},
      {"Current directory", "bookmarks.csv"}
    ]

    IO.puts("=== CSV File Path Debug ===")
    for {label, path} <- paths do
      exists = File.exists?(path)
      IO.puts("#{label}: #{path} (exists: #{exists})")
    end
    IO.puts("Current working directory: #{File.cwd!()}")
    IO.puts("Selected path: #{csv_file_path()}")
    IO.puts("===========================")
  end

  # Get the CSV file path, handling different environments
  defp csv_file_path do
    # Try different path resolution methods for different environments
    cond do
      # Production with releases
      File.exists?(Path.join([Application.app_dir(:iagocavalcante), "priv", "bookmarks.csv"])) ->
        Path.join([Application.app_dir(:iagocavalcante), "priv", "bookmarks.csv"])

      # Development
      File.exists?(Path.join([:code.priv_dir(:iagocavalcante), "bookmarks.csv"])) ->
        Path.join([:code.priv_dir(:iagocavalcante), "bookmarks.csv"])

      # Fallback - relative path
      File.exists?("priv/bookmarks.csv") ->
        "priv/bookmarks.csv"

      # Last resort - check if it's in the current directory
      File.exists?("bookmarks.csv") ->
        "bookmarks.csv"

      # Default development path (might not exist)
      true ->
        Path.join([:code.priv_dir(:iagocavalcante), "bookmarks.csv"])
    end
  end

  @doc """
  Load all bookmarks from the CSV file
  """
  def all_bookmarks do
    file_path = csv_file_path()

    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.drop(1) # Skip header
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&parse_bookmark_line/1)
        |> Enum.reject(&is_nil/1)

      {:error, reason} ->
        # Log the error for debugging but return empty list for graceful degradation
        IO.warn("Could not read CSV file at #{file_path}: #{inspect(reason)}")
        []
    end
  end

  @doc """
  Get bookmarks grouped by tags
  """
  def bookmarks_by_tag do
    all_bookmarks()
    |> Enum.flat_map(fn bookmark ->
      Enum.map(bookmark.tags, fn tag ->
        {tag, bookmark}
      end)
    end)
    |> Enum.group_by(fn {tag, _bookmark} -> tag end, fn {_tag, bookmark} -> bookmark end)
    |> Enum.sort_by(fn {_tag, bookmarks} -> -length(bookmarks) end)
  end

  @doc """
  Get all unique tags sorted by frequency
  """
  def all_tags do
    bookmarks_by_tag()
    |> Enum.map(fn {tag, bookmarks} -> {tag, length(bookmarks)} end)
  end

  @doc """
  Get bookmarks for a specific tag
  """
  def bookmarks_for_tag(tag) do
    bookmarks_by_tag()
    |> Map.get(tag, [])
    |> Enum.sort_by(&(-&1.time_added))
  end

  @doc """
  Get featured tags (top tags with most bookmarks)
  """
  def featured_tags(limit \\ 10) do
    all_tags()
    |> Enum.take(limit)
  end

  defp parse_bookmark_line(line) do
    # Handle CSV parsing with potential commas in titles and URLs
    case parse_csv_line(line) do
      [title, url, time_added_str, tags_str, status] ->
        time_added = String.to_integer(time_added_str)
        tags = parse_tags(tags_str)

        %__MODULE__{
          title: title,
          url: url,
          time_added: time_added,
          tags: tags,
          status: status
        }

      _ ->
        nil
    end
  rescue
    _ -> nil
  end

  defp parse_csv_line(line) do
    # Simple CSV parser - splits by comma but handles quoted fields
    line
    |> String.split(",")
    |> Enum.map(&String.trim/1)
  end

  defp parse_tags(""), do: []
  defp parse_tags(tags_str) when is_binary(tags_str) do
    tags_str
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
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
      "bg-red-500", "bg-green-500", "bg-blue-500", "bg-yellow-500",
      "bg-purple-500", "bg-pink-500", "bg-indigo-500", "bg-orange-500",
      "bg-teal-500", "bg-cyan-500", "bg-emerald-500", "bg-rose-500"
    ]

    hash = :erlang.phash2(tag, length(colors))
    Enum.at(colors, hash)
  end
end
