defmodule Iagocavalcante.Blog do
  alias Iagocavalcante.Post

  defmodule NotFoundError, do: defexception([:message, plug_status: 404])

  use NimblePublisher,
    build: Post,
    from: Application.fetch_env!(:iagocavalcante, :blog_post_path) <> "/**/*.md",
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

  def update_post(id, attrs) do
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
end
