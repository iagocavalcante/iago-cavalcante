defmodule IagocavalcanteWeb.Events do
  use Phoenix.Component
  import IagocavalcanteWeb.Gettext

  attr :events, :list,
    default: [
      %{
        event: "IdopterLabs Talks",
        title: "Where have you vue?",
        year: "2021",
        link: "https://www.youtube.com/watch?v=4QlwElMV_JI",
        description:
          "Internal presentation at Idopter Labs Talks, showcasing the latest updates on my favorite framework, Vue 3."
      },
      %{
        event: "DevOpsDays - Belém",
        title: "Starting with DevOps in personal projects",
        year: "2018",
        link:
          "https://docs.google.com/presentation/d/e/2PACX-1vTD2rAv41sGiTCyqlHw1ly_7g1FDqe_V3riCOLEpbcebcrYPsPdci4oRbj4RP6WYWN3Io445ujnl7z4/pub?start=false&loop=false&delayms=3000#slide=id.gcb9a0b074_1_0",
        description:
          "I see a lot of people wanting to start with DevOps or understand it better, but it can be difficult to practice in your work environment. So, nothing better than starting with something that is yours and that will probably cost you almost nothing. That is the main goal of this talk, to get out of inertia and get your hands dirty."
      }
    ]
  attr :locale, :string, default: "en"

  def events(assigns) do
    ~H"""
    <article :for={event <- @events} class="group relative flex flex-col items-start">
      <h3 class="text-base font-semibold tracking-tight text-zinc-800 dark:text-zinc-100">
        <div class="absolute -inset-y-6 -inset-x-4 z-0 scale-95 bg-zinc-50 opacity-0 transition group-hover:scale-100 group-hover:opacity-100 dark:bg-zinc-800/50 sm:-inset-x-6 sm:rounded-2xl">
        </div>
        <a href="/speaking#">
          <span class="absolute -inset-y-6 -inset-x-4 z-20 sm:-inset-x-6 sm:rounded-2xl"></span><span class="relative z-10"><%= event.title %></span>
        </a>
      </h3>
      <p class="relative z-10 order-first mb-3 flex items-center text-sm text-zinc-400 dark:text-zinc-500 pl-3.5">
        <span class="absolute inset-y-0 left-0 flex items-center" aria-hidden="true">
          <span class="h-4 w-0.5 rounded-full bg-zinc-200 dark:bg-zinc-500"></span>
        </span>
        <%= "#{event.event} #{event.year}" %>
      </p>
      <p class="relative z-10 mt-2 text-sm text-zinc-600 dark:text-zinc-400">
        <%= event.description %>
      </p>
      <div
        aria-hidden="true"
        class="relative z-10 mt-4 flex items-center text-sm font-medium text-teal-500"
      >
        <%= gettext("Link to presentation or video", lang: @locale) %><svg
          viewBox="0 0 16 16"
          fill="none"
          aria-hidden="true"
          class="ml-1 h-4 w-4 stroke-current"
        ><path
            d="M6.75 5.75 9.25 8l-2.5 2.25"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          ></path></svg>
      </div>
    </article>
    """
  end
end
