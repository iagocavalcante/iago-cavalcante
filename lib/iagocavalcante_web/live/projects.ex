defmodule IagocavalcanteWeb.ProjectsLive do
  use IagocavalcanteWeb, :live_view

  def render(assigns) do
    ~H"""
    <main>
      <div class="sm:px-8 mt-8 sm:mt-16">
        <div class="mx-auto max-w-7xl lg:px-8">
          <div class="relative px-4 sm:px-8 lg:px-12">
            <div class="mx-auto max-w-2xl lg:max-w-5xl">
              <header class="max-w-2xl">
                <h1 class="text-4xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                  <%= gettext("Things I’ve made trying to put my dent in the universe.", lang: @locale) %>
                </h1>
                <p class="mt-6 text-base text-zinc-600 dark:text-zinc-400">
                  <%= gettext(
                    "I’ve worked on tons of little projects over the years but these are the ones that I’m most proud of. Many of them are open-source, so if you see something that piques your interest, check out the code and contribute if you have ideas for how it can be improved.",
                    lang: @locale
                  ) %>
                </p>
              </header>
              <div class="mt-16 sm:mt-20">
                <.categories_projects />
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
    """
  end
end
