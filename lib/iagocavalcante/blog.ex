defmodule Iagocavalcante.Blog do
  alias Iagocavalcante.Post
  alias Iagocavalcante.Blog.Comment
  alias Iagocavalcante.Blog.CommentNotifier
  alias Iagocavalcante.Repo
  import Ecto.Query

  defmodule NotFoundError, do: defexception([:message, plug_status: 404])

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:iagocavalcante, "priv/posts/**/*.md"),
    as: :posts,
    html_converter: Iagocavalcante.Blog.MDExConverter

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  def all_tags, do: @tags
  def all_posts, do: @posts

  def published_posts, do: Enum.filter(all_posts(), &(&1.published == true))

  def published_posts_by_locale(locale) do
    published_posts()
    |> Enum.filter(&(&1.locale == locale))
  end

  def draft_posts, do: Enum.filter(all_posts(), &(&1.published == false))

  def posts_by_status(status \\ :all) do
    case status do
      :published -> published_posts()
      :draft -> draft_posts()
      :all -> all_posts()
    end
  end

  def recent_posts(num \\ 5), do: Enum.take(published_posts(), num)

  def recent_posts_by_locale(num \\ 5, locale),
    do: Enum.take(published_posts_by_locale(locale), num)

  @doc """
  Returns paginated posts for a given locale.

  ## Options
    * `:page` - The page number (default: 1)
    * `:per_page` - Number of posts per page (default: 10)

  Returns a map with:
    * `:posts` - List of posts for the current page
    * `:page` - Current page number
    * `:per_page` - Posts per page
    * `:total_posts` - Total number of posts
    * `:total_pages` - Total number of pages
    * `:has_prev` - Whether there's a previous page
    * `:has_next` - Whether there's a next page
  """
  def paginate_posts_by_locale(locale, opts \\ []) do
    page = max(opts[:page] || 1, 1)
    per_page = opts[:per_page] || 10

    all_posts = published_posts_by_locale(locale)
    total_posts = length(all_posts)
    total_pages = max(ceil(total_posts / per_page), 1)
    page = min(page, total_pages)

    posts =
      all_posts
      |> Enum.drop((page - 1) * per_page)
      |> Enum.take(per_page)

    %{
      posts: posts,
      page: page,
      per_page: per_page,
      total_posts: total_posts,
      total_pages: total_pages,
      has_prev: page > 1,
      has_next: page < total_pages
    }
  end

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
    locale = attrs["locale"]
    year = attrs["year"]
    slug = attrs["slug"]

    # Validate inputs
    with :ok <- validate_locale(locale),
         :ok <- validate_year(year),
         :ok <- validate_slug(slug) do
      %Post{
        id: slug,
        title: attrs["title"],
        description: attrs["description"],
        body: attrs["body"],
        tags: attrs["tags"] || "~w()",
        published: attrs["published"] || true,
        date: Date.utc_today(),
        locale: locale,
        author: "Iago Cavalcante",
        path: attrs["path"],
        year: year
      }
      |> insert_header_in_body()
      |> create_markdown_file()
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def update_post(id, attrs) do
    try do
      post = get_post_by_id!(id)

      updated_post =
        %Post{
          id: attrs["slug"] || post.id,
          title: attrs["title"] || post.title,
          description: attrs["description"] || post.description,
          body: attrs["body"] || post.body,
          tags: attrs["tags"] || Enum.join(post.tags, ", "),
          published: attrs["published"] || post.published,
          date: post.date,
          locale: attrs["locale"] || post.locale,
          author: post.author,
          path: post.path,
          year: post.year
        }
        |> insert_header_in_body()

      # Write updated content to the existing file
      full_path = resolve_post_path(post.path, post.locale, post.year)

      case File.write(full_path, updated_post.body) do
        :ok ->
          # If slug changed, rename the file
          if attrs["slug"] && attrs["slug"] != post.id do
            new_path = create_new_path_from_slug(attrs["slug"], post)
            new_full_path = resolve_post_path(new_path, post.locale, post.year)

            case File.rename(full_path, new_full_path) do
              :ok -> :ok
              error -> error
            end
          else
            :ok
          end

        error ->
          error
      end
    rescue
      error -> {:error, error}
    end
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

  @allowed_locales ~w(en pt_BR)
  @allowed_year_range 2020..2100

  defp resolve_post_path(path, locale, year) do
    base_path = Application.fetch_env!(:iagocavalcante, :blog_post_path)
    full_path = Path.join([base_path, locale, to_string(year), path])

    # Validate the path is within the allowed directory
    case validate_path(full_path, base_path) do
      :ok -> full_path
      {:error, reason} -> raise "Invalid path: #{reason}"
    end
  end

  defp validate_path(full_path, base_path) do
    # Expand paths to resolve any .. or symlinks
    expanded_full = Path.expand(full_path)
    expanded_base = Path.expand(base_path)

    cond do
      # Ensure path stays within base directory
      not String.starts_with?(expanded_full, expanded_base) ->
        {:error, "path traversal detected"}

      # Ensure file has .md extension
      not String.ends_with?(full_path, ".md") ->
        {:error, "invalid file extension"}

      true ->
        :ok
    end
  end

  defp validate_locale(locale) when locale in @allowed_locales, do: :ok
  defp validate_locale(_locale), do: {:error, "invalid locale"}

  defp validate_year(year) when is_integer(year) and year in @allowed_year_range, do: :ok
  defp validate_year(_year), do: {:error, "invalid year"}

  defp validate_slug(slug) when is_binary(slug) do
    # Only allow alphanumeric, hyphens, and underscores
    if Regex.match?(~r/^[a-zA-Z0-9_-]+$/, slug) do
      :ok
    else
      {:error, "invalid slug characters"}
    end
  end

  defp validate_slug(_slug), do: {:error, "slug must be a string"}

  defp create_new_path_from_slug(slug, post) do
    # Validate slug before using
    case validate_slug(slug) do
      :ok ->
        case String.split(post.path, "-", parts: 3) do
          [month, day, _] -> "#{month}-#{day}-#{slug}.md"
          _ -> "#{slug}.md"
        end

      {:error, reason} ->
        raise "Invalid slug: #{reason}"
    end
  end

  # Comments functions

  @max_reply_depth 5

  @doc """
  Lists all comments for a post with nested replies loaded efficiently.

  Uses a single query to fetch all comments and builds the tree in memory,
  avoiding N+1 queries from recursive database calls.
  """
  def list_comments_for_post(post_id, status \\ :approved) do
    # Fetch all comments for the post in a single query
    all_comments =
      from(c in Comment,
        where: c.post_id == ^post_id and c.status == ^status,
        order_by: [asc: c.inserted_at]
      )
      |> Repo.all()

    # Build the comment tree in memory
    build_comment_tree(all_comments)
  end

  # Build nested comment tree from flat list
  defp build_comment_tree(comments) do
    # Group comments by parent_id
    by_parent = Enum.group_by(comments, & &1.parent_id)

    # Get root comments (no parent)
    root_comments = Map.get(by_parent, nil, [])

    # Recursively attach replies
    root_comments
    |> Enum.map(&attach_replies(&1, by_parent, 0))
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
  end

  defp attach_replies(comment, _by_parent, depth) when depth >= @max_reply_depth do
    %{comment | replies: []}
  end

  defp attach_replies(comment, by_parent, depth) do
    replies =
      by_parent
      |> Map.get(comment.id, [])
      |> Enum.map(&attach_replies(&1, by_parent, depth + 1))
      |> Enum.sort_by(& &1.inserted_at, {:asc, DateTime})

    %{comment | replies: replies}
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
    |> maybe_notify_admin()
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

  def delete_comment(id) do
    get_comment!(id)
    |> Repo.delete()
  end

  def get_comment!(id), do: Repo.get!(Comment, id)

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

  defp maybe_notify_admin({:ok, comment}) do
    if comment.status == :pending do
      # Send email notification to admin about pending comment
      # Use Task.Supervisor for graceful shutdown handling
      Task.Supervisor.start_child(Iagocavalcante.TaskSupervisor, fn ->
        case get_post_by_id!(comment.post_id) do
          post when not is_nil(post) ->
            CommentNotifier.deliver_new_pending_comment(%{comment: comment, post: post})

          _ ->
            :ok
        end
      end)
    end

    {:ok, comment}
  end

  defp maybe_notify_admin(error), do: error

  def comment_count_for_post(post_id) do
    from(c in Comment,
      where: c.post_id == ^post_id and c.status == :approved
    )
    |> Repo.aggregate(:count)
  end
end
