defmodule IagocavalcanteWeb.Admin.PostsLive.New do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog

  @impl true
  def mount(_params, _session, socket) do
    pending_comments_count = Blog.list_pending_comments() |> length()

    {:ok,
     socket
     |> assign(:current_page, :posts)
     |> assign(:pending_comments_count, pending_comments_count)}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:post, %{})}
  end

  @impl true
  def handle_info({:update_notification_progress, component_id, progress}, socket) do
    send_update(IagocavalcanteWeb.Admin.PostsLive.FormComponent,
      id: component_id,
      notification_progress: progress
    )

    # Auto-close modal and redirect after completion
    if progress.status in [:completed, :error] do
      Process.send_after(self(), {:close_modal_and_redirect, component_id, progress}, 2000)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:close_modal_and_redirect, _component_id, progress}, socket) do
    message =
      case progress.status do
        :completed -> "Post published and #{progress.sent} notification(s) sent!"
        :error -> "Post published. #{progress.sent} sent, #{progress.failed} failed."
      end

    {:noreply,
     socket
     |> put_flash(:info, message)
     |> push_navigate(to: ~p"/admin/posts")}
  end

  defp page_title(:new), do: "New Post"
end
