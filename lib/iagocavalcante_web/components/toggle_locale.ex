defmodule IagocavalcanteWeb.ToggleLocale do
  use Phoenix.Component

  def toggle_locale(assigns) do
    ~H"""
    <button
      phx-click="toggle_locale"
      type="button"
      aria-label="Toggle locale"
      class="group rounded-full bg-white/90 px-3 py-2 shadow-lg shadow-zinc-800/5 ring-1 ring-zinc-900/5 backdrop-blur transition dark:bg-zinc-800/90 dark:ring-white/10 dark:hover:ring-white/20"
    >
      <svg
        viewBox="0 0 24 24"
        aria-hidden="true"
        class="hidden h-6 w-6 fill-zinc-700 stroke-zinc-500 transition dark:block [@media(prefers-color-scheme:dark)]:group-hover:stroke-zinc-400 [@media_not_(prefers-color-scheme:dark)]:fill-teal-400/10 [@media_not_(prefers-color-scheme:dark)]:stroke-teal-500"
      >
        <path
          d="M17.25 16.22a6.937 6.937 0 0 1-9.47-9.47 7.451 7.451 0 1 0 9.47 9.47ZM12.75 7C17 7 17 2.75 17 2.75S17 7 21.25 7C17 7 17 11.25 17 11.25S17 7 12.75 7Z"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
        </path>
      </svg>
    </button>
    """
  end

  # def toggle_locale(%{locale: "dark"} = assigns) do
  #   ~H"""
  #   <button
  #     phx-click="toggle_locale"
  #     type="button"
  #     aria-label="Toggle dark mode"
  #     class="group rounded-full bg-white/90 px-3 py-2 shadow-lg shadow-zinc-800/5 ring-1 ring-zinc-900/5 backdrop-blur transition dark:bg-zinc-800/90 dark:ring-white/10 dark:hover:ring-white/20"
  #   >
  #     <svg
  #       viewBox="0 0 24 24"
  #       aria-hidden="true"
  #       class="hidden h-6 w-6 fill-zinc-700 stroke-zinc-500 transition dark:block [@media(prefers-color-scheme:dark)]:group-hover:stroke-zinc-400 [@media_not_(prefers-color-scheme:dark)]:fill-teal-400/10 [@media_not_(prefers-color-scheme:dark)]:stroke-teal-500"
  #     >
  #       <path
  #         d="M17.25 16.22a6.937 6.937 0 0 1-9.47-9.47 7.451 7.451 0 1 0 9.47 9.47ZM12.75 7C17 7 17 2.75 17 2.75S17 7 21.25 7C17 7 17 11.25 17 11.25S17 7 12.75 7Z"
  #         stroke-width="1.5"
  #         stroke-linecap="round"
  #         stroke-linejoin="round"
  #       >
  #       </path>
  #     </svg>
  #   </button>
  #   """
  # end

  def handle_event("toggle_locale", %{"locale" => locale}, socket) do
    locale = if locale == "light", do: "dark", else: "light"
    socket = assign(socket, :locale, locale)
    {:noreply, socket}
  end
end
