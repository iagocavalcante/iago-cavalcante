defmodule IagocavalcanteWeb.Admin.PostsLive.New do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:post, %{})}
  end

  defp page_title(:new), do: "New Post"
end
