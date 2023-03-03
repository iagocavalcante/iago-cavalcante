defmodule IagocavalcanteWeb.HomeLive do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :last_articles, Blog.list_last_posts())}
  end

  def render(assigns) do
    ~H"""
    <div class="sm:px-8 mt-9">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <div class="max-w-2xl">
              <%= @locale %>
              <h1 class="text-4xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                <%= gettext("Software alchemist, co-founder, and maker.", lang: @locale) %>
              </h1>
              <p class="mt-6 text-base text-zinc-600 dark:text-zinc-400">
                <%= gettext(
                  "I’m Iago, a software alchemist (elixir dev) and entrepreneur based in Belém. I’m the co-founder and CTO of Japu and Travessia, where we develop marketplace and SaaS for education."
                ) %>
              </p>
              <div class="mt-6 flex gap-6">
                <.social_links
                  link="https://twitter.com/iagoangelimc"
                  only_icon={true}
                  social="twitter"
                />
                <.social_links
                  link="https://instagram.com/iago_cavalcante"
                  only_icon={true}
                  social="instagram"
                />
                <.social_links
                  link="https://github.com/iagocavalcante"
                  only_icon={true}
                  social="github"
                />
                <.social_links
                  link="https://linkedin.com/in/iago-a-cavalcante"
                  only_icon={true}
                  social="linkedin"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="mt-16 sm:mt-20">
      <div class="-my-4 flex justify-center gap-5 overflow-hidden py-4 sm:gap-8">
        <.photos />
      </div>
    </div>
    <div class="sm:px-8 mt-24 md:mt-28">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <div class="mx-auto grid max-w-xl grid-cols-1 gap-y-20 lg:max-w-none lg:grid-cols-2">
              <div class="flex flex-col gap-16">
                <.posts articles={@last_articles} />
              </div>
              <div class="space-y-10 lg:pl-16 xl:pl-24">
                <.live_component module={IagocavalcanteWeb.Newsletter} id="newsletter" />
                <div class="rounded-2xl border border-zinc-100 p-6 dark:border-zinc-700/40">
                  <h2 class="flex text-sm font-semibold text-zinc-900 dark:text-zinc-100">
                    <svg
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke-width="1.5"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      aria-hidden="true"
                      class="h-6 w-6 flex-none"
                    >
                      <path
                        d="M2.75 9.75a3 3 0 0 1 3-3h12.5a3 3 0 0 1 3 3v8.5a3 3 0 0 1-3 3H5.75a3 3 0 0 1-3-3v-8.5Z"
                        class="fill-zinc-100 stroke-zinc-400 dark:fill-zinc-100/10 dark:stroke-zinc-500"
                      >
                      </path>
                      <path
                        d="M3 14.25h6.249c.484 0 .952-.002 1.316.319l.777.682a.996.996 0 0 0 1.316 0l.777-.682c.364-.32.832-.319 1.316-.319H21M8.75 6.5V4.75a2 2 0 0 1 2-2h2.5a2 2 0 0 1 2 2V6.5"
                        class="stroke-zinc-400 dark:stroke-zinc-500"
                      >
                      </path>
                    </svg>
                    <span class="ml-3"><%= gettext("Work") %></span>
                  </h2>
                  <ol class="mt-6 space-y-4">
                    <.work />
                  </ol>
                  <a
                    class="inline-flex items-center gap-2 justify-center rounded-md py-2 px-3 text-sm outline-offset-2 transition active:transition-none bg-zinc-50 font-medium text-zinc-900 hover:bg-zinc-100 active:bg-zinc-100 active:text-zinc-900/60 dark:bg-zinc-800/50 dark:text-zinc-300 dark:hover:bg-zinc-800 dark:hover:text-zinc-50 dark:active:bg-zinc-800/50 dark:active:text-zinc-50/70 group mt-6 w-full"
                    href="https://www.linkedin.com/in/iago-a-cavalcante/?locale=en_US"
                    download
                    target="_blank"
                  >
                    <%= gettext("Download CV") %><svg
                      viewBox="0 0 16 16"
                      fill="none"
                      aria-hidden="true"
                      class="h-4 w-4 stroke-zinc-400 transition group-active:stroke-zinc-600 dark:group-hover:stroke-zinc-50 dark:group-active:stroke-zinc-50"
                    ><path
                        d="M4.75 8.75 8 12.25m0 0 3.25-3.5M8 12.25v-8.5"
                        stroke-width="1.5"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      ></path></svg>
                  </a>
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
