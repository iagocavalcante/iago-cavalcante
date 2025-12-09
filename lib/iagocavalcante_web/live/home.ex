defmodule IagocavalcanteWeb.HomeLive do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog

  def render(assigns) do
    ~H"""
    <!-- Hero Section - Clean Editorial Design -->
    <div class="relative sm:px-8 mt-12 sm:mt-20">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <div class="max-w-2xl">
              <!-- Section Label -->
              <div class="section-title mb-8">
                <span><%= gettext("Introduction", lang: @locale) %></span>
              </div>

              <!-- Main Heading - Editorial Typography -->
              <h1 class="text-4xl sm:text-5xl lg:text-6xl font-display font-semibold tracking-tight leading-tight animate-fade-in">
                <span class="text-ink">
                  <%= gettext("Software engineer,", lang: @locale) %>
                </span>
                <br />
                <span class="text-ink">
                  <%= gettext("builder, and", lang: @locale) %>
                </span>
                <br />
                <span class="text-accent">
                  <%= gettext("Elixir enthusiast.", lang: @locale) %>
                </span>
              </h1>

              <!-- Description - Clean prose -->
              <p class="mt-8 text-lg text-ink-light leading-relaxed animate-slide-up stagger-1">
                <%= gettext(
                  "I'm Iago, a software engineer and entrepreneur based in Belém, Brazil. Currently working at EasyMate AI building intelligent solutions. Previously co-founded Japu and Travessia, and now focused on building Agendflow.",
                  lang: @locale
                ) %>
              </p>

              <!-- Social Links - Minimal Style -->
              <div class="mt-8 flex gap-6 animate-slide-up stagger-2">
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

    <!-- Photo Gallery - Clean with subtle borders -->
    <div class="mt-16 sm:mt-20">
      <div class="-my-4 flex justify-center gap-5 overflow-hidden py-4 sm:gap-8">
        <.photos />
      </div>
    </div>

    <!-- Main Content Grid -->
    <div class="sm:px-8 mt-24 md:mt-28">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <div class="mx-auto grid max-w-xl grid-cols-1 gap-y-20 lg:max-w-none lg:grid-cols-2">
              <!-- Recent Articles -->
              <div class="flex flex-col">
                <div class="section-title">
                  <span><%= gettext("Recent Articles", lang: @locale) %></span>
                </div>
                <div class="mt-6">
                  <.posts articles={Blog.recent_posts_by_locale(@locale)} locale={@locale} />
                </div>
              </div>

              <!-- Sidebar -->
              <div class="space-y-10 lg:pl-16 xl:pl-24">
                <!-- Newsletter Card -->
                <.live_component
                  module={IagocavalcanteWeb.Newsletter}
                  id="newsletter"
                  locale={@locale}
                />

                <!-- Work Experience Card -->
                <div class="editorial-card">
                  <h2 class="flex items-center text-sm font-mono uppercase tracking-wider text-muted mb-6">
                    <svg
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke-width="1.5"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      aria-hidden="true"
                      class="h-5 w-5 flex-none stroke-current"
                    >
                      <path
                        d="M2.75 9.75a3 3 0 0 1 3-3h12.5a3 3 0 0 1 3 3v8.5a3 3 0 0 1-3 3H5.75a3 3 0 0 1-3-3v-8.5Z"
                      />
                      <path
                        d="M3 14.25h6.249c.484 0 .952-.002 1.316.319l.777.682a.996.996 0 0 0 1.316 0l.777-.682c.364-.32.832-.319 1.316-.319H21M8.75 6.5V4.75a2 2 0 0 1 2-2h2.5a2 2 0 0 1 2 2V6.5"
                      />
                    </svg>
                    <span class="ml-3"><%= gettext("Work", lang: @locale) %></span>
                  </h2>

                  <ol class="space-y-0">
                    <.work />
                  </ol>

                  <a
                    class="btn-secondary w-full mt-6 text-sm"
                    href="https://www.linkedin.com/in/iago-a-cavalcante/?locale=en_US"
                    target="_blank"
                  >
                    <%= gettext("Download CV", lang: @locale) %>
                    <svg
                      viewBox="0 0 16 16"
                      fill="none"
                      aria-hidden="true"
                      class="h-4 w-4 ml-2 stroke-current"
                    >
                      <path
                        d="M4.75 8.75 8 12.25m0 0 3.25-3.5M8 12.25v-8.5"
                        stroke-width="1.5"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      />
                    </svg>
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
