defmodule Iagocavalcante.Blog do
  alias Iagocavalcante.Post

  defmodule NotFoundError, do: defexception [:message, plug_status: 404]

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
    |> Enum.filter(& &1.locale == locale)
  end
  def recent_posts(num \\ 5), do: Enum.take(published_posts(), num)
  def recent_posts_by_locale(num \\ 5, locale), do: Enum.take(published_posts_by_locale(locale), num)

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
end
