defmodule Iagocavalcante.Bookmarks.Bookmark do
  @moduledoc """
  Schema for bookmarks
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :id

  schema "bookmarks" do
    field :title, :string
    field :url, :string
    field :description, :string
    field :tags, {:array, :string}, default: []
    field :status, :string, default: "unread"
    field :archived, :boolean, default: false
    field :favorite, :boolean, default: false
    field :read_time_minutes, :integer
    field :source, :string, default: "extension" # "extension", "import", "manual"
    field :domain, :string
    field :added_at, :utc_datetime

    belongs_to :user, Iagocavalcante.Accounts.User

    timestamps()
  end

  @doc false
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
    |> validate_required([:title, :url, :user_id])
    |> validate_url(:url)
    |> validate_inclusion(:status, ["unread", "read", "archived"])
    |> validate_inclusion(:source, ["extension", "import", "manual"])
    |> put_domain_from_url()
    |> put_added_at()
    |> unique_constraint([:url, :user_id], name: :bookmarks_url_user_id_index)
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
      nil -> changeset
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
