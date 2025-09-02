defmodule IagocavalcanteWeb.Admin.PostsLive.Index do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog

  @impl true
  def mount(_params, _session, socket) do
    pending_comments_count = Blog.list_pending_comments() |> length()
    
    {:ok, 
     socket
     |> stream(:posts_collection, Blog.all_posts())
     |> assign(:current_page, :posts)
     |> assign(:pending_comments_count, pending_comments_count)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Posts")
    |> assign(:posts, Blog.get_post_by_id!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Posts")
    |> assign(:post, %{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:posts, nil)
  end

  @impl true
  def handle_info({IagocavalcanteWeb.Admin.PostsLive.FormComponent, {:saved, posts}}, socket) do
    {:noreply, stream_insert(socket, :posts_collection, posts)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    try do
      Blog.delete_post(id)
      {:noreply, socket |> put_flash(:info, "Posts deleted successfully")}
    rescue
      _ ->
        {:noreply, socket |> put_flash(:error, "Failed to delete post")}
    end
  end

end
