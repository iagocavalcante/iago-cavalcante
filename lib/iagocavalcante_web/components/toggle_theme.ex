defmodule IagocavalcanteWeb.ToggleTheme do
  use Phoenix.Component

  def toggle_theme(assigns) do
    ~H"""
    <button
      id="theme-toggle"
      phx-update="ignore"
      phx-hook="DarkThemeToggle"
      type="button"
      aria-label="Toggle dark mode"
      class="toggle-btn group relative flex items-center justify-center w-9 h-9 rounded-full transition-all duration-300 hover:bg-stone-100 dark:hover:bg-stone-800"
    >
      <!-- Moon icon (shown in dark mode) -->
      <svg
        id="theme-toggle-dark-icon"
        viewBox="0 0 24 24"
        aria-hidden="true"
        class="h-[18px] w-[18px] transition-all duration-300 group-hover:scale-110 group-hover:rotate-12"
        style="fill: var(--muted); stroke: var(--ink-light);"
      >
        <path
          d="M17.25 16.22a6.937 6.937 0 0 1-9.47-9.47 7.451 7.451 0 1 0 9.47 9.47ZM12.75 7C17 7 17 2.75 17 2.75S17 7 21.25 7C17 7 17 11.25 17 11.25S17 7 12.75 7Z"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
        </path>
      </svg>
      <!-- Sun icon (shown in light mode) -->
      <svg
        id="theme-toggle-light-icon"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
        class="hidden h-[18px] w-[18px] transition-all duration-300 group-hover:scale-110 group-hover:rotate-45"
        style="fill: var(--paper-dark); stroke: var(--ink-light);"
      >
        <path d="M8 12.25A4.25 4.25 0 0 1 12.25 8v0a4.25 4.25 0 0 1 4.25 4.25v0a4.25 4.25 0 0 1-4.25 4.25v0A4.25 4.25 0 0 1 8 12.25v0Z">
        </path>
        <path
          d="M12.25 3v1.5M21.5 12.25H20M18.791 18.791l-1.06-1.06M18.791 5.709l-1.06 1.06M12.25 20v1.5M4.5 12.25H3M6.77 6.77 5.709 5.709M6.77 17.73l-1.061 1.061"
          fill="none"
        >
        </path>
      </svg>
    </button>

    <script>
      // Initialize theme icons immediately (before LiveView mounts)
      (function() {
        const darkIcon = document.getElementById('theme-toggle-dark-icon');
        const lightIcon = document.getElementById('theme-toggle-light-icon');
        if (darkIcon && lightIcon) {
          const isDark = localStorage.getItem('theme') === 'dark' ||
            (!localStorage.getItem('theme') && window.matchMedia('(prefers-color-scheme: dark)').matches);
          if (isDark) {
            darkIcon.classList.remove('hidden');
            lightIcon.classList.add('hidden');
          } else {
            darkIcon.classList.add('hidden');
            lightIcon.classList.remove('hidden');
          }
        }
      })();
    </script>
    """
  end
end
