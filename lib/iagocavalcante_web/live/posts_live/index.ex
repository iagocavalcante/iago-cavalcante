defmodule IagocavalcanteWeb.PostsLive.Index do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog
  alias Iagocavalcante.Blog.Posts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :posts_collection, Blog.list_posts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Posts")
    |> assign(:posts, Blog.get_posts!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Posts")
    |> assign(:posts, %Posts{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:posts, nil)
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
