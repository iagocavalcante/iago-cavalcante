defmodule Iagocavalcante.Blog do
  alias Iagocavalcante.Post
  alias Iagocavalcante.Blog.Comment
  alias Iagocavalcante.Repo
  import Ecto.Query

  defmodule NotFoundError, do: defexception([:message, plug_status: 404])

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:iagocavalcante, "priv/posts/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang]

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  def all_tags, do: @tags
  def all_posts, do: @posts

  def published_posts, do: Enum.filter(all_posts(), &(&1.published == true))

  def published_posts_by_locale(locale) do
    published_posts()
    |> Enum.filter(&(&1.locale == locale))
  end

  def recent_posts(num \\ 5), do: Enum.take(published_posts(), num)

  def recent_posts_by_locale(num \\ 5, locale),
    do: Enum.take(published_posts_by_locale(locale), num)

  def get_post_by_id!(id) do
    Enum.find(all_posts(), &(&1.id == id)) ||
      raise NotFoundError, "post with id=#{id} not found"
  end

  def get_posts_by_tag!(tag) do
    case Enum.filter(published_posts(), &(tag in &1.tags)) do
      [] -> raise NotFoundError, "posts with tag=#{tag} not found"
      posts -> posts
    end
  end

  def create_new_post(attrs) do
    %Post{
      id: attrs["slug"],
      title: attrs["title"],
      description: attrs["description"],
      body: attrs["body"],
      tags: attrs["tags"] || "~w()",
      published: attrs["published"] || true,
      date: Date.utc_today(),
      locale: attrs["locale"],
      author: "Iago Cavalcante",
      path: attrs["path"],
      year: attrs["year"]
    }
    |> insert_header_in_body()
    |> create_markdown_file()
  end

  def update_post(_id, _attrs) do
    # TODO: Implement post update functionality
    {:error, :not_implemented}
  end

  def delete_post(id) do
    post = get_post_by_id!(id)
    renamed_html_to_md = post.path |> String.replace(".html", ".md")
    File.rm!(renamed_html_to_md)
  end

  defp create_markdown_file(post) do
    full_path =
      Path.join(
        Application.fetch_env!(:iagocavalcante, :blog_post_path) <> "#{post.locale}/#{post.year}/",
        post.path
      )

    File.write(full_path, post.body)
  end

  defp insert_header_in_body(post) do
    header = """
    %{
      title: "#{post.title}",
      description: "#{post.description}",
      tags: ~w(#{split_tags(post.tags)}),
      published: #{post.published},
      locale: "#{post.locale}",
      author: "Iago Cavalcante"
    }
    ---

    """

    post |> Map.put(:body, header <> post.body)
  end

  defp split_tags(tags) do
    tags
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.downcase/1)
    |> Enum.join(" ")
  end

  # Comments functions
  def list_comments_for_post(post_id, status \\ :approved) do
    from(c in Comment,
      where: c.post_id == ^post_id and c.status == ^status,
      where: is_nil(c.parent_id),
      order_by: [desc: c.inserted_at],
      preload: [:replies]
    )
    |> Repo.all()
    |> Enum.map(&load_nested_replies/1)
  end

  def list_pending_comments do
    from(c in Comment,
      where: c.status == :pending,
      order_by: [desc: c.inserted_at]
    )
    |> Repo.all()
  end

  def create_comment(attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
    |> maybe_auto_approve()
  end

  def approve_comment(id) do
    get_comment!(id)
    |> Comment.changeset(%{status: "approved"})
    |> Repo.update()
  end

  def reject_comment(id) do
    get_comment!(id)
    |> Comment.changeset(%{status: "rejected"})
    |> Repo.update()
  end

  def mark_as_spam(id) do
    get_comment!(id)
    |> Comment.changeset(%{status: "spam"})
    |> Repo.update()
  end

  def get_comment!(id), do: Repo.get!(Comment, id)

  defp load_nested_replies(comment) do
    replies = 
      from(c in Comment,
        where: c.parent_id == ^comment.id and c.status == :approved,
        order_by: [asc: c.inserted_at]
      )
      |> Repo.all()
      |> Enum.map(&load_nested_replies/1)

    %{comment | replies: replies}
  end

  defp maybe_auto_approve({:ok, comment}) do
    cond do
      comment.spam_score >= 0.7 ->
        # High spam score - mark as spam
        {:ok, comment} = 
          comment
          |> Comment.changeset(%{status: "spam"})
          |> Repo.update()
        
        {:ok, comment}
      
      comment.spam_score <= 0.3 and trusted_commenter?(comment.author_email) ->
        # Low spam score and trusted commenter - auto approve
        {:ok, comment} =
          comment
          |> Comment.changeset(%{status: "approved"})
          |> Repo.update()
        
        {:ok, comment}
      
      true ->
        # Medium spam score - keep as pending for manual review
        {:ok, comment}
    end
  end

  defp maybe_auto_approve(error), do: error

  defp trusted_commenter?(email) do
    # Check if this email has had comments approved before
    approved_count = 
      from(c in Comment,
        where: c.author_email == ^email and c.status == :approved
      )
      |> Repo.aggregate(:count)

    approved_count >= 3
  end

  def comment_count_for_post(post_id) do
    from(c in Comment,
      where: c.post_id == ^post_id and c.status == :approved
    )
    |> Repo.aggregate(:count)
  end
end
