defmodule Iagocavalcante.Blog.Comment do
  @moduledoc """
  Schema for blog post comments with spam detection and nested replies.

  Note: Post validation is done in the Blog context, not in the schema,
  to avoid cross-context coupling.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Iagocavalcante.Blog.SpamDetector
  alias Iagocavalcante.Ecto.Sanitizer

  @statuses ~w(pending approved rejected spam)a

  schema "comments" do
    field :post_id, :string
    field :author_name, :string
    field :author_email, :string
    field :content, :string
    field :status, Ecto.Enum, values: @statuses, default: :pending
    field :ip_address, :string
    field :user_agent, :string
    field :spam_score, :float, default: 0.0

    belongs_to :parent, __MODULE__, foreign_key: :parent_id
    has_many :replies, __MODULE__, foreign_key: :parent_id, preload_order: [asc: :inserted_at]

    timestamps()
  end

  @cast_fields ~w(post_id author_name author_email content status ip_address user_agent spam_score parent_id)a
  @sanitize_fields ~w(author_name author_email content ip_address user_agent)a

  @doc """
  Changeset for creating a new comment.
  Includes spam score calculation.
  """
  def create_changeset(comment, attrs) do
    comment
    |> cast(attrs, @cast_fields)
    |> Sanitizer.sanitize_fields(@sanitize_fields)
    |> validate_required([:post_id, :author_name, :author_email, :content])
    |> validate_format(:author_email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_length(:author_name, min: 2, max: 50)
    |> validate_length(:content, min: 10, max: 2000)
    |> put_spam_score()
  end

  @doc """
  Changeset for updating comment content (edit by admin).
  """
  def update_changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content])
    |> Sanitizer.sanitize_fields([:content])
    |> validate_length(:content, min: 10, max: 2000)
  end

  @doc """
  Lightweight changeset for status changes only.
  Does not recalculate spam score.
  """
  def status_changeset(comment, status) when status in @statuses do
    comment
    |> change(%{status: status})
  end

  def status_changeset(comment, status) when is_binary(status) do
    status_changeset(comment, String.to_existing_atom(status))
  rescue
    ArgumentError -> add_error(change(comment), :status, "invalid status")
  end

  @doc """
  Legacy changeset - kept for backwards compatibility.
  Prefer create_changeset/2 for new comments, status_changeset/2 for status changes.
  """
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, @cast_fields)
    |> Sanitizer.sanitize_fields(@sanitize_fields)
    |> validate_required([:post_id, :author_name, :author_email, :content])
    |> validate_format(:author_email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_length(:author_name, min: 2, max: 50)
    |> validate_length(:content, min: 10, max: 2000)
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:spam_score, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
  end

  defp put_spam_score(changeset) do
    case get_field(changeset, :content) do
      nil ->
        changeset

      content ->
        spam_score =
          SpamDetector.calculate(
            content,
            get_field(changeset, :author_name),
            get_field(changeset, :author_email)
          )

        put_change(changeset, :spam_score, spam_score)
    end
  end

  def approved_statuses, do: [:approved]
  def pending_statuses, do: [:pending]
  def spam_statuses, do: [:spam, :rejected]
  def all_statuses, do: @statuses
end
