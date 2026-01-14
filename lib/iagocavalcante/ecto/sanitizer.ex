defmodule Iagocavalcante.Ecto.Sanitizer do
  @moduledoc """
  Input sanitization utilities for Ecto changesets.

  PostgreSQL rejects null bytes even though they're valid UTF-8.
  This module provides helpers to sanitize user input at boundaries.
  """

  import Ecto.Changeset

  @doc """
  Removes null bytes from a string.

  Returns nil for nil input, unchanged for non-strings.
  """
  @spec sanitize_string(String.t() | nil) :: String.t() | nil
  def sanitize_string(nil), do: nil
  def sanitize_string(str) when is_binary(str), do: String.replace(str, "\0", "")
  def sanitize_string(other), do: other

  @doc """
  Sanitizes a list of strings, removing null bytes from each.
  """
  @spec sanitize_string_list(list(String.t()) | nil) :: list(String.t()) | nil
  def sanitize_string_list(nil), do: nil

  def sanitize_string_list(list) when is_list(list) do
    Enum.map(list, &sanitize_string/1)
  end

  def sanitize_string_list(other), do: other

  @doc """
  Sanitizes multiple fields in a changeset.

  ## Examples

      changeset
      |> sanitize_fields([:email, :name, :content])
  """
  @spec sanitize_fields(Ecto.Changeset.t(), list(atom())) :: Ecto.Changeset.t()
  def sanitize_fields(changeset, fields) when is_list(fields) do
    Enum.reduce(fields, changeset, fn field, cs ->
      update_change(cs, field, &sanitize_string/1)
    end)
  end

  @doc """
  Sanitizes array fields (like tags) in a changeset.
  """
  @spec sanitize_array_fields(Ecto.Changeset.t(), list(atom())) :: Ecto.Changeset.t()
  def sanitize_array_fields(changeset, fields) when is_list(fields) do
    Enum.reduce(fields, changeset, fn field, cs ->
      update_change(cs, field, &sanitize_string_list/1)
    end)
  end
end
