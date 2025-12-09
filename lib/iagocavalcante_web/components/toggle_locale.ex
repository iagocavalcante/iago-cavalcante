defmodule IagocavalcanteWeb.ToggleLocale do
  use Phoenix.Component

  def toggle_locale(assigns) do
    ~H"""
    <button
      phx-click="toggle_locale"
      phx-value-locale={@locale}
      type="button"
      aria-label="Toggle locale"
      class="toggle-btn group relative flex items-center justify-center w-9 h-9 rounded-full transition-all duration-300 hover:bg-stone-100 dark:hover:bg-stone-800"
    >
      <img
        src={"/images/flags/#{@locale}.png"}
        class="h-5 w-5 rounded-sm transition-all duration-300 group-hover:scale-110"
      />
    </button>
    """
  end
end
