defmodule IagocavalcanteWeb.SubscriberVerifyLive do
  use IagocavalcanteWeb, :live_view

  def mount(%{"token" => token}, _assigns, socket) do
    case Iagocavalcante.Subscribers.verify_subscriber(socket, token) do
      {:ok, _subscriber} ->
        {:ok, socket |> assign(:token, token)}

      {:error, _reason} ->
        {:ok, socket |> assign(:token, nil)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="sm:px-8 mt-16 sm:mt-32">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <div class="lg:order-first lg:row-span-2">
              <h2 class="text-3xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                <%= if is_nil(@token) do %>
                  {gettext("Invalid token.", lang: @locale)}
                <% else %>
                  {gettext("Email verified. Thanks <3", lang: @locale)}
                <% end %>
              </h2>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
