defmodule IagocavalcanteWeb.Admin.PostsLive.Index do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog
  alias Iagocavalcante.Subscribers

  @impl true
  def mount(_params, _session, socket) do
    pending_comments_count = Blog.list_pending_comments() |> length()
    subscriber_count = Subscribers.count_verified_subscribers()

    {:ok,
     socket
     |> assign(:current_page, :posts)
     |> assign(:pending_comments_count, pending_comments_count)
     |> assign(:subscriber_count, subscriber_count)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:posts, Blog.get_post_by_id!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:posts, %{})
  end

  defp apply_action(socket, :index, params) do
    filter =
      case params["filter"] do
        "published" -> :published
        "draft" -> :draft
        _ -> :all
      end

    posts = Blog.posts_by_status(filter)

    socket
    |> stream(:posts_collection, posts, reset: true)
    |> assign(:page_title, "Listing Posts")
    |> assign(:posts, nil)
    |> assign(:current_filter, filter)
    |> assign(:posts_count, length(posts))
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

  @impl true
  def handle_event("notify_subscribers", %{"id" => id}, socket) do
    case Blog.get_post_by_id(id) do
      {:ok, post} ->
        if post.published do
          # Build post params for notification
          post_params = %{
            "title" => post.title,
            "description" => post.description,
            "slug" => post.id,
            "locale" => post.locale
          }

          # Send notifications asynchronously
          Task.Supervisor.start_child(Iagocavalcante.TaskSupervisor, fn ->
            Subscribers.notify_new_post(post_params)
          end)

          subscriber_count = socket.assigns.subscriber_count

          {:noreply,
           socket
           |> put_flash(:info, "Sending notifications to #{subscriber_count} subscribers...")}
        else
          {:noreply, socket |> put_flash(:error, "Cannot notify subscribers about a draft post")}
        end

      {:error, :not_found} ->
        {:noreply, socket |> put_flash(:error, "Post not found")}
    end
  end
end
