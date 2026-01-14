defmodule Iagocavalcante.Blog.SpamDetector do
  @moduledoc """
  Spam detection service for blog comments.

  Calculates a spam score between 0.0 and 1.0 based on:
  - Excessive links in content
  - Suspicious keywords
  - Author name/email mismatch
  - Content quality issues
  """

  @spam_keywords ~w(buy cheap discount offer free money casino viagra cialis loan credit)

  @doc """
  Calculate spam score for a comment.

  Returns a float between 0.0 (not spam) and 1.0 (definitely spam).
  """
  @spec calculate(String.t(), String.t() | nil, String.t() | nil) :: float()
  def calculate(content, author_name, author_email) do
    [
      {&check_excessive_links/1, 0.3},
      {&check_suspicious_keywords/1, 0.25},
      {&check_name_email_mismatch/2, 0.2},
      {&check_content_quality/1, 0.25}
    ]
    |> Enum.reduce(0.0, fn
      {{func, weight}, acc} when is_function(func, 1) ->
        acc + func.(content) * weight

      {{func, weight}, acc} when is_function(func, 2) ->
        acc + func.(author_name, author_email) * weight
    end)
    |> min(1.0)
  end

  defp check_excessive_links(content) do
    link_count = Regex.scan(~r/https?:\/\//, content) |> length()

    cond do
      link_count >= 5 -> 1.0
      link_count >= 3 -> 0.7
      link_count >= 2 -> 0.4
      true -> 0.0
    end
  end

  defp check_suspicious_keywords(content) do
    content_lower = String.downcase(content)

    matches =
      Enum.count(@spam_keywords, fn keyword ->
        String.contains?(content_lower, keyword)
      end)

    min(matches / 5, 1.0)
  end

  defp check_name_email_mismatch(nil, _email), do: 0.0
  defp check_name_email_mismatch(_name, nil), do: 0.0

  defp check_name_email_mismatch(name, email) do
    name_part = name |> String.downcase() |> String.replace(~r/\s+/, "")
    email_part = email |> String.split("@") |> hd() |> String.downcase()

    if String.jaro_distance(name_part, email_part) < 0.3, do: 0.5, else: 0.0
  end

  defp check_content_quality(content) do
    cond do
      String.length(content) < 20 -> 0.6
      # ALL CAPS detection
      Regex.match?(~r/^[A-Z\s!]{10,}$/, content) -> 0.8
      # Repeated characters
      Regex.match?(~r/(.)\1{4,}/, content) -> 0.7
      true -> 0.0
    end
  end
end
