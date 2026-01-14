defmodule Iagocavalcante.Bookmarks.Cache do
  @moduledoc """
  ETS-based cache for CSV bookmarks.

  Loads bookmarks from CSV at startup and caches them in ETS for fast access.
  Provides invalidation mechanism for updates.
  """

  use GenServer

  @table_name :bookmarks_cache
  @csv_key :all_bookmarks
  @by_tag_key :bookmarks_by_tag

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Get all bookmarks from cache.
  """
  def all_bookmarks do
    case :ets.lookup(@table_name, @csv_key) do
      [{@csv_key, bookmarks}] -> bookmarks
      [] -> []
    end
  end

  @doc """
  Get bookmarks grouped by tag from cache.
  """
  def bookmarks_by_tag do
    case :ets.lookup(@table_name, @by_tag_key) do
      [{@by_tag_key, by_tag}] -> by_tag
      [] -> []
    end
  end

  @doc """
  Invalidate cache and reload from CSV.
  """
  def invalidate do
    GenServer.cast(__MODULE__, :invalidate)
  end

  # Server callbacks

  @impl true
  def init(_opts) do
    # Create ETS table owned by this process
    :ets.new(@table_name, [:named_table, :public, read_concurrency: true])

    # Load initial data
    load_bookmarks()

    {:ok, %{}}
  end

  @impl true
  def handle_cast(:invalidate, state) do
    load_bookmarks()
    {:noreply, state}
  end

  # Private functions

  defp load_bookmarks do
    bookmarks = parse_csv_file()

    # Cache all bookmarks
    :ets.insert(@table_name, {@csv_key, bookmarks})

    # Cache bookmarks by tag
    by_tag = group_by_tag(bookmarks)
    :ets.insert(@table_name, {@by_tag_key, by_tag})
  end

  defp parse_csv_file do
    file_path = csv_file_path()

    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.drop(1)
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&parse_bookmark_line/1)
        |> Enum.reject(&is_nil/1)

      {:error, _reason} ->
        []
    end
  end

  defp csv_file_path do
    cond do
      File.exists?(Path.join([Application.app_dir(:iagocavalcante), "priv", "bookmarks.csv"])) ->
        Path.join([Application.app_dir(:iagocavalcante), "priv", "bookmarks.csv"])

      File.exists?(Path.join([:code.priv_dir(:iagocavalcante), "bookmarks.csv"])) ->
        Path.join([:code.priv_dir(:iagocavalcante), "bookmarks.csv"])

      File.exists?("priv/bookmarks.csv") ->
        "priv/bookmarks.csv"

      File.exists?("bookmarks.csv") ->
        "bookmarks.csv"

      true ->
        Path.join([:code.priv_dir(:iagocavalcante), "bookmarks.csv"])
    end
  end

  defp parse_bookmark_line(line) do
    case String.split(line, ",") |> Enum.map(&String.trim/1) do
      [title, url, time_added_str, tags_str, status] ->
        %Iagocavalcante.Bookmarks{
          title: title,
          url: url,
          time_added: String.to_integer(time_added_str),
          tags: parse_tags(tags_str),
          status: status
        }

      _ ->
        nil
    end
  rescue
    _ -> nil
  end

  defp parse_tags(""), do: []

  defp parse_tags(tags_str) do
    tags_str
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
  end

  defp group_by_tag(bookmarks) do
    bookmarks
    |> Enum.flat_map(fn bookmark ->
      Enum.map(bookmark.tags, fn tag -> {tag, bookmark} end)
    end)
    |> Enum.group_by(fn {tag, _bookmark} -> tag end, fn {_tag, bookmark} -> bookmark end)
    |> Enum.sort_by(fn {_tag, bookmarks} -> -length(bookmarks) end)
  end
end
