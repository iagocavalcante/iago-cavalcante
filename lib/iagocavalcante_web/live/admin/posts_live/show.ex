defmodule IagocavalcanteWeb.Admin.PostsLive.Show do
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
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:posts, Blog.get_post_by_id!(id))}
  end

  defp page_title(:show), do: "Show Posts"
  defp page_title(:edit), do: "Edit Posts"
end
