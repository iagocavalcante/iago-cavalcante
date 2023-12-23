defmodule IagocavalcanteWeb.ArticlesLive.Comments do
  use IagocavalcanteWeb, :live_component

  attr :id, :string, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= @id %>
    </div>
    """
  end
end
