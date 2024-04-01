defmodule IagocavalcanteWeb.UsesLive do
  use IagocavalcanteWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="sm:px-8 mt-8 sm:mt-16">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <header class="max-w-2xl">
              <h1 class="text-4xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                <%= gettext("Software I use, gadgets I love, and other things I recommend.",
                  lang: @locale
                ) %>
              </h1>
              <p class="mt-6 text-base text-zinc-600 dark:text-zinc-400">
                <%= gettext(
                  "I’ve been using a lot of different software and hardware over the years, but now I've finally stopped to focus on selecting and maintaining cool gadgets and equipment for work and productivity.",
                  lang: @locale
                ) %>
              </p>
            </header>
            <div class="mt-16 sm:mt-20">
              <div class="space-y-20">
                <.categories_uses />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
