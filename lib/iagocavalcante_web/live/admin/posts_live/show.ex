defmodule IagocavalcanteWeb.Admin.PostsLive.Show do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
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
