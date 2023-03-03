defmodule IagocavalcanteWeb.ToggleLocale do
  use Phoenix.Component

  import IagocavalcanteWeb.Gettext

  def toggle_locale(assigns) do
    ~H"""
    <button
      phx-click="toggle_locale"
      phx-value-locale={@locale}
      type="button"
      aria-label="Toggle locale"
      class="group rounded-full bg-white/90 px-3 py-2 shadow-lg shadow-zinc-800/5 ring-1 ring-zinc-900/5 backdrop-blur transition dark:bg-zinc-800/90 dark:ring-white/10 dark:hover:ring-white/20"
    >
      <img
        src={"/images/flags/#{@locale}.png"}
        class="h-6 w-6 fill-zinc-700 stroke-zinc-500 transition dark:fill-teal-400/10 dark:stroke-teal-500"
      />
    </button>
    """
  end

  # def handle_event("toggle_locale", %{"locale" => "en"}, socket) do
  #   locale = "pt_BR"
  #   IO.inspect(locale, label: "handle_event")
  #   perform_assigns(socket, locale)
  # end

  # def handle_event("toggle_locale", %{"locale" => "pt_BR"}, socket) do
  #   locale = "en"
  #   IO.inspect(locale, label: "handle_event")
  #   perform_assigns(socket, locale)
  # end

  # defp perform_assigns(socket, locale) do
  #   new_socket = socket |> assign(locale: locale)
  #   IO.inspect(locale, label: "perform_assigns")

  #   current_path = choose_path(socket.view)
  #   # remove / from the beginning of the path
  #   current_path = String.replace(current_path, "/", "")
  #   Gettext.put_locale(locale)
  #   IO.inspect(current_path, label: "current_path")

  #   {:noreply, new_socket}
  # end

  # defp choose_path(view) do
  #   case view do
  #     IagocavalcanteWeb.HomeLive -> "/"
  #     IagocavalcanteWeb.AboutLive -> gettext("/about")
  #     IagocavalcanteWeb.ArticlesLive.Index -> gettext("/articles")
  #     IagocavalcanteWeb.ProjectsLive -> gettext("/projects")
  #     IagocavalcanteWeb.SpeakingLive -> gettext("/speaking")
  #     IagocavalcanteWeb.UsesLive -> gettext("/uses")
  #   end
  # end
end
