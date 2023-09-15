defmodule IagocavalcanteWeb.ArticlesLive.Index do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog

  def render(assigns) do
    ~H"""
    <div class="sm:px-8 mt-16 sm:mt-32">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <header class="max-w-2xl">
              <h1 class="text-4xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                <%= gettext(
                  "I write about software in general, and now I want to talk more about hardware and IoT.",
                  lang: @locale
                ) %>
              </h1>
              <p class="mt-6 text-base text-zinc-600 dark:text-zinc-400">
                <%= gettext(
                  "Here will be centralized all the old and current posts and thoughts, with tips and some solutions that I have implemented throughout my career.",
                  lang: @locale
                ) %>
              </p>
            </header>
            <div class="mt-16 sm:mt-20">
              <div class="md:border-l md:border-zinc-100 md:pl-6 md:dark:border-zinc-700/40">
                <div class="flex max-w-3xl flex-col space-y-16">
                  <.articles_list articles={Blog.published_posts_by_locale(@locale)} locale={@locale} />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
