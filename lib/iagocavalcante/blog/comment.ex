defmodule Iagocavalcante.Blog.Comment do
  @moduledoc """
  Schema for blog post comments with spam detection and nested replies.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Iagocavalcante.Blog.SpamDetector

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

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [
      :post_id,
      :author_name,
      :author_email,
      :content,
      :status,
      :ip_address,
      :user_agent,
      :spam_score,
      :parent_id
    ])
    |> validate_required([:post_id, :author_name, :author_email, :content])
    |> validate_format(:author_email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_length(:author_name, min: 2, max: 50)
    |> validate_length(:content, min: 10, max: 2000)
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:spam_score, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> validate_post_exists()
    |> put_spam_score()
  end

  defp validate_post_exists(changeset) do
    case get_field(changeset, :post_id) do
      nil ->
        changeset

      post_id ->
        try do
          Iagocavalcante.Blog.get_post_by_id!(post_id)
          changeset
        rescue
          Iagocavalcante.Blog.NotFoundError ->
            add_error(changeset, :post_id, "post does not exist")
        end
    end
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
end
