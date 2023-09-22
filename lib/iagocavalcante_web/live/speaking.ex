defmodule IagocavalcanteWeb.SpeakingLive do
  use IagocavalcanteWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="sm:px-8 mt-16 sm:mt-32">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <header class="max-w-2xl">
              <h1 class="text-4xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                <%= gettext("I have already given some talks in my region and for internal events.",
                  lang: @locale
                ) %>
              </h1>
              <p class="mt-6 text-base text-zinc-600 dark:text-zinc-400">
                <%= gettext(
                  "Although I enjoy sharing content at events, I still get very nervous and appear very little. But I continue to help the community as the manager of the North devs community and by organizing monthly events.",
                  lang: @locale
                ) %>
              </p>
            </header>
            <div class="mt-16 sm:mt-20">
              <div class="space-y-20">
                <section
                  aria-labelledby=":r1:"
                  class="md:border-l md:border-zinc-100 md:pl-6 md:dark:border-zinc-700/40"
                >
                  <div class="grid max-w-3xl grid-cols-1 items-baseline gap-y-8 md:grid-cols-4">
                    <h2 id=":r1:" class="text-sm font-semibold text-zinc-800 dark:text-zinc-100">
                      <%= gettext("Events", lang: @locale) %>
                    </h2>
                    <div class="md:col-span-3">
                      <div class="space-y-16">
                        <.events locale={@locale} />
                      </div>
                    </div>
                  </div>
                </section>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
