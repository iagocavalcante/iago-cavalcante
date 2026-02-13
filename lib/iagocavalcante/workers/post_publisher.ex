defmodule Iagocavalcante.Workers.PostPublisher do
  @moduledoc """
  Oban cron worker that runs daily to detect newly-published scheduled posts.

  Posts become visible via runtime date filter in Blog.published_posts/0.
  This worker handles side effects: logging and future notifications.
  """

  use Oban.Worker, queue: :default

  require Logger

  alias Iagocavalcante.Blog

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    posts = Blog.newly_published_posts()

    if Enum.any?(posts) do
      Enum.each(posts, fn post ->
        Logger.info("Scheduled post now live: #{post.title} (#{post.locale})")
      end)
    end

    {:ok, %{published_count: length(posts)}}
  end
end
