defmodule IagocavalcanteWeb.PostsLive.Editor do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog
  alias Iagocavalcante.Blog.Post

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
      |> assign(:page_title, "New Post")
      |> assign(:form, to_form(%{body: "asdasdas"}))
    {:ok, socket}
  end

  @impl true
  def handle_info({IagocavalcanteWeb.PostsLive.FormComponent, {:saved, posts}}, socket) do
    {:noreply, stream_insert(socket, :posts_collection, posts)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    posts = Blog.get_posts!(id)
    {:ok, _} = Blog.delete_posts(posts)

    {:noreply, stream_delete(socket, :posts_collection, posts)}
  end
end
