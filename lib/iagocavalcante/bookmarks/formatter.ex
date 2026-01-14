defmodule Iagocavalcante.Bookmarks.Formatter do
  @moduledoc """
  Presentation helpers for bookmarks.

  These functions are purely for display/formatting and should be used
  in views or LiveView components, not in the context business logic.
  """

  @doc """
  Convert Unix timestamp to readable date string.

  ## Examples

      iex> format_date(1609459200)
      "2021-01-01"
  """
  @spec format_date(integer()) :: String.t()
  def format_date(timestamp) when is_integer(timestamp) do
    timestamp
    |> DateTime.from_unix!()
    |> DateTime.to_date()
    |> Date.to_string()
  end

  @doc """
  Extract domain from URL for display.

  ## Examples

      iex> get_domain("https://example.com/path")
      "example.com"

      iex> get_domain("invalid")
      ""
  """
  @spec get_domain(String.t()) :: String.t()
  def get_domain(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: host} when is_binary(host) -> host
      _ -> ""
    end
  end

  def get_domain(_), do: ""

  @doc """
  Get initials for a tag (for avatar/badge display).

  ## Examples

      iex> tag_initials("web-development")
      "WD"

      iex> tag_initials("elixir")
      "EL"
  """
  @spec tag_initials(String.t()) :: String.t()
  def tag_initials(tag) when is_binary(tag) do
    tag
    |> String.split(["-", "_", " "])
    |> Enum.map(&String.first/1)
    |> Enum.take(2)
    |> Enum.join("")
    |> String.upcase()
  end

  def tag_initials(_), do: ""

  @colors [
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

  @doc """
  Get a consistent color class for a tag based on its hash.

  Returns a Tailwind CSS background color class.

  ## Examples

      iex> tag_color("elixir")
      "bg-purple-500"
  """
  @spec tag_color(String.t()) :: String.t()
  def tag_color(tag) when is_binary(tag) do
    hash = :erlang.phash2(tag, length(@colors))
    Enum.at(@colors, hash)
  end

  def tag_color(_), do: hd(@colors)
end
