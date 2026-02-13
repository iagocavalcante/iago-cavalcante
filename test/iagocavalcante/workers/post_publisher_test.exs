defmodule Iagocavalcante.Workers.PostPublisherTest do
  use Iagocavalcante.DataCase, async: true
  use Oban.Testing, repo: Iagocavalcante.Repo

  alias Iagocavalcante.Workers.PostPublisher

  test "perform/1 returns ok with published count" do
    assert {:ok, %{published_count: _count}} = perform_job(PostPublisher, %{})
  end
end
