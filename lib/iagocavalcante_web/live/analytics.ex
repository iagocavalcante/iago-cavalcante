defmodule IagocavalcanteWeb.AnalyticsLive do
  use IagocavalcanteWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="sm:px-8 mt-8 sm:mt-16">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <header class="max-w-2xl">
              <h1 class="text-4xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                <%= gettext("You can see the site analytics.",
                  lang: @locale
                ) %>
              </h1>
            </header>
            <div class="mt-16 sm:mt-20">
              <div class="space-y-20">
                <iframe
                  plausible-embed
                  src="https://devsnorte-plausible.fly.dev/share/iagocavalcante.com?auth=hzmTXjI1FHNvpcyIN3vrp&embed=true&theme=system"
                  scrolling="no"
                  frameborder="0"
                  loading="lazy"
                  style="width: 1px; min-width: 100%; height: 1600px;"
                >
                </iframe>
                <div style="font-size: 14px; padding-bottom: 14px;">
                  <%= gettext("Stats powered by",
                    lang: @locale
                  ) %>
                  <a
                    target="_blank"
                    style="color: #4F46E5; text-decoration: underline;"
                    href="https://plausible.io"
                  >
                    Plausible Analytics
                  </a>
                </div>
                <script async src="https://devsnorte-plausible.fly.dev/js/embed.host.js">
                </script>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
