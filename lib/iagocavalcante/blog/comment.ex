defmodule Iagocavalcante.Blog.Comment do
  use Ecto.Schema
  import Ecto.Changeset

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
    has_many :replies, __MODULE__, foreign_key: :parent_id

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:post_id, :author_name, :author_email, :content, :status, :ip_address, :user_agent, :spam_score, :parent_id])
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
      nil -> changeset
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
      nil -> changeset
      content -> 
        spam_score = calculate_spam_score(content, get_field(changeset, :author_name), get_field(changeset, :author_email))
        put_change(changeset, :spam_score, spam_score)
    end
  end

  # Simple spam detection algorithm
  defp calculate_spam_score(content, name, email) do
    score = 0.0
    
    # Check for suspicious patterns
    score = score + check_excessive_links(content) * 0.3
    score = score + check_suspicious_keywords(content) * 0.25
    score = score + check_name_email_mismatch(name, email) * 0.2
    score = score + check_content_quality(content) * 0.25
    
    min(score, 1.0)
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
    spam_keywords = ~w(buy cheap discount offer free money casino viagra cialis loan credit)
    content_lower = String.downcase(content)
    
    matches = Enum.count(spam_keywords, fn keyword ->
      String.contains?(content_lower, keyword)
    end)
    
    min(matches / 5, 1.0)
  end

  defp check_name_email_mismatch(name, email) do
    if name && email do
      name_part = String.downcase(name) |> String.replace(~r/\s+/, "")
      email_part = String.split(email, "@") |> hd() |> String.downcase()
      
      if String.jaro_distance(name_part, email_part) < 0.3, do: 0.5, else: 0.0
    else
      0.0
    end
  end

  defp check_content_quality(content) do
    cond do
      String.length(content) < 20 -> 0.6
      Regex.match?(~r/^[A-Z\s!]{10,}$/, content) -> 0.8  # ALL CAPS
      Regex.match?(~r/(.)\1{4,}/, content) -> 0.7  # Repeated characters
      true -> 0.0
    end
  end

  def approved_statuses, do: [:approved]
  def pending_statuses, do: [:pending]
  def spam_statuses, do: [:spam, :rejected]
end