defmodule IagocavalcanteWeb.AboutLive do
  use IagocavalcanteWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="sm:px-8 mt-8 sm:mt-16">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <div class="grid grid-cols-1 gap-y-16 lg:grid-cols-2 lg:grid-rows-[auto_1fr] lg:gap-y-12">
              <div class="lg:pl-20">
                <div class="max-w-xs px-2.5 lg:max-w-none">
                  <img
                    alt=""
                    sizes="(min-width: 1024px) 32rem, 20rem"
                    srcset="/images/myself-3.jpeg"
                    src="/images/myself-3.jpeg"
                    decoding="async"
                    data-nimg="1"
                    class="aspect-square rounded-2xl bg-zinc-100 object-cover dark:bg-zinc-800"
                    loading="lazy"
                    style="color: transparent;"
                    width="800"
                    height="800"
                  />
                </div>
              </div>
              <div class="lg:order-first lg:row-span-2">
                <h1 class="text-4xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                  <%= gettext(
                    "I'm Iago Cavalcante. I live in Belém, Brazil. I'm a software alchemist and community lover.",
                    lang: @locale
                  ) %>
                </h1>
                <div class="mt-6 space-y-7 text-base text-zinc-600 dark:text-zinc-400">
                  <p>
                    <%= gettext(
                      "I have been a curious person since childhood, greatly inspired by what my grandfather built and fixed. I always knew that I wanted to be an electrical or computer engineer. During my teenage years, I loved computers and video games, and that's when I made the final decision to study Computer Engineering.",
                      lang: @locale
                    ) %>
                  </p>
                  <p>
                    <%= gettext(
                      "During college, I discovered my passion for programming and building hardware. After graduation, I continued to build things for fun using Arduinos, Raspberry Pis, and ESPs. I also discovered that I enjoyed helping people and even giving talks (even though I was always very shy about speaking to other people).",
                      lang: @locale
                    ) %>
                  </p>
                  <p>
                    <%= gettext(
                      "In 2018, my friends Patrick and Amir came up with the idea of starting a movement in our city called VueJs Norte, which is now called DevsNorte. Today, with new organizers, we hold monthly events on a variety of technology topics and try to help people who are just starting out in the field.",
                      lang: @locale
                    ) %>
                  </p>
                  <p>
                    <%= gettext(
                      "In addition to trying to create content in my spare time and mentoring people who are entering the field, I am now a partner with Juliana Ranieri where we are developing a marketplace platform for hardware stores called Japu. I also work full-time as a software engineer for the consultancy firm Truelogic and for a client directly in the United States.",
                      lang: @locale
                    ) %>
                  </p>
                </div>
              </div>
              <div class="lg:pl-20">
                <ul role="list">
                  <li class="flex">
                    <.social_links
                      link="https://twitter.com/iagoangelimc"
                      social="twitter"
                      locale={@locale}
                    />
                  </li>
                  <li class="mt-4 flex">
                    <.social_links
                      link="https://instagram.com/iago_cavalcante"
                      social="instagram"
                      locale={@locale}
                    />
                  </li>
                  <li class="mt-4 flex">
                    <.social_links
                      link="https://github.com/iagocavalcante"
                      social="github"
                      locale={@locale}
                    />
                  </li>
                  <li class="mt-4 flex">
                    <.social_links
                      link="https://linkedin.com/in/iago-a-cavalcante"
                      social="linkedin"
                      locale={@locale}
                    />
                  </li>
                  <li class="mt-8 border-t border-zinc-100 pt-8 dark:border-zinc-700/40 flex">
                    <a
                      class="group flex text-sm font-medium text-zinc-800 transition hover:text-teal-500 dark:text-zinc-200 dark:hover:text-teal-500"
                      href="mailto:iagocavalcante@hey.com"
                    >
                      <svg
                        viewBox="0 0 24 24"
                        aria-hidden="true"
                        class="h-6 w-6 flex-none fill-zinc-500 transition group-hover:fill-teal-500"
                      >
                        <path
                          fill-rule="evenodd"
                          d="M6 5a3 3 0 0 0-3 3v8a3 3 0 0 0 3 3h12a3 3 0 0 0 3-3V8a3 3 0 0 0-3-3H6Zm.245 2.187a.75.75 0 0 0-.99 1.126l6.25 5.5a.75.75 0 0 0 .99 0l6.25-5.5a.75.75 0 0 0-.99-1.126L12 12.251 6.245 7.187Z"
                        >
                        </path>
                      </svg>
                      <span class="ml-4">iagocavalcante@hey.com</span>
                    </a>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
