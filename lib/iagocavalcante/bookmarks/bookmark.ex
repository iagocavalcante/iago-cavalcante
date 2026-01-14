defmodule Iagocavalcante.Bookmarks.Bookmark do
  @moduledoc """
  Schema for bookmarks.

  Note: user_id is stored as a plain field to avoid cross-context coupling.
  Use Accounts.get_user!/1 when you need user data.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Iagocavalcante.Ecto.Sanitizer

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :id

  @statuses ~w(unread read archived)a
  @sources ~w(extension import manual)a

  schema "bookmarks" do
    field :title, :string
    field :url, :string
    field :description, :string
    field :tags, {:array, :string}, default: []
    field :status, Ecto.Enum, values: @statuses, default: :unread
    field :archived, :boolean, default: false
    field :favorite, :boolean, default: false
    field :read_time_minutes, :integer
    field :source, Ecto.Enum, values: @sources, default: :extension
    field :domain, :string
    field :added_at, :utc_datetime
    # Store user_id as plain field - avoids cross-context coupling
    field :user_id, :id

    timestamps()
  end

  @doc """
  Changeset for creating a new bookmark.
  """
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [
      :title,
      :url,
      :description,
      :tags,
      :status,
      :archived,
      :favorite,
      :read_time_minutes,
      :source,
      :domain,
      :added_at,
      :user_id
    ])
    |> Sanitizer.sanitize_fields([:title, :url, :description, :domain])
    |> Sanitizer.sanitize_array_fields([:tags])
    |> validate_required([:title, :url, :user_id])
    |> validate_length(:title, min: 1, max: 500)
    |> validate_length(:description, max: 2000)
    |> validate_number(:read_time_minutes, greater_than_or_equal_to: 0, less_than: 1000)
    |> validate_url(:url)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:source, @sources)
    |> put_domain_from_url()
    |> put_added_at()
    |> unique_constraint([:url, :user_id], name: :bookmarks_url_user_id_index)
  end

  @doc """
  Changeset for updating bookmark status only.
  """
  def status_changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:status])
    |> validate_inclusion(:status, @statuses)
  end

  @doc """
  Changeset for toggling favorite status.
  """
  def favorite_changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:favorite])
  end

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, url ->
      case URI.parse(url) do
        %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and not is_nil(host) ->
          []

        _ ->
          [{field, "must be a valid HTTP or HTTPS URL"}]
      end
    end)
  end

  defp put_domain_from_url(changeset) do
    case get_change(changeset, :url) do
      nil ->
        changeset

      url ->
        case URI.parse(url) do
          %URI{host: host} when is_binary(host) ->
            put_change(changeset, :domain, host)

          _ ->
            changeset
        end
    end
  end

  defp put_added_at(changeset) do
    case get_field(changeset, :added_at) do
      nil -> put_change(changeset, :added_at, DateTime.utc_now())
      _ -> changeset
    end
  end
end
