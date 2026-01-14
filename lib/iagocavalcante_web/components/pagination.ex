defmodule IagocavalcanteWeb.Pagination do
  use Phoenix.Component
  use Gettext, backend: IagocavalcanteWeb.Gettext

  attr :page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :has_prev, :boolean, required: true
  attr :has_next, :boolean, required: true
  attr :total_posts, :integer, required: true
  attr :path, :string, default: "/articles"

  def pagination(assigns) do
    ~H"""
    <nav
      :if={@total_pages > 1}
      class="flex items-center justify-between border-t border-zinc-100 dark:border-zinc-700/40 pt-6 mt-12"
      aria-label="Pagination"
    >
      <div class="hidden sm:block">
        <p class="text-sm text-zinc-500 dark:text-zinc-400">
          {gettext("Page")} <span class="font-medium text-zinc-700 dark:text-zinc-200">{@page}</span>
          {gettext("of")}
          <span class="font-medium text-zinc-700 dark:text-zinc-200">{@total_pages}</span>
          <span class="text-zinc-400 dark:text-zinc-500 mx-2">·</span>
          <span class="font-medium text-zinc-700 dark:text-zinc-200">{@total_posts}</span> {gettext(
            "articles"
          )}
        </p>
      </div>

      <div class="flex flex-1 justify-between sm:justify-end gap-3">
        <.page_link
          :if={@has_prev}
          href={"#{@path}?page=#{@page - 1}"}
          direction={:prev}
        />
        <span
          :if={!@has_prev}
          class="relative inline-flex items-center px-4 py-2 text-sm font-medium text-zinc-300 dark:text-zinc-600 cursor-not-allowed"
        >
          <svg class="h-4 w-4 mr-1.5" viewBox="0 0 20 20" fill="currentColor">
            <path
              fill-rule="evenodd"
              d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z"
              clip-rule="evenodd"
            />
          </svg>
          {gettext("Previous")}
        </span>

        <.page_link
          :if={@has_next}
          href={"#{@path}?page=#{@page + 1}"}
          direction={:next}
        />
        <span
          :if={!@has_next}
          class="relative inline-flex items-center px-4 py-2 text-sm font-medium text-zinc-300 dark:text-zinc-600 cursor-not-allowed"
        >
          {gettext("Next")}
          <svg class="h-4 w-4 ml-1.5" viewBox="0 0 20 20" fill="currentColor">
            <path
              fill-rule="evenodd"
              d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
              clip-rule="evenodd"
            />
          </svg>
        </span>
      </div>
    </nav>
    """
  end

  attr :href, :string, required: true
  attr :direction, :atom, required: true

  defp page_link(assigns) do
    ~H"""
    <a
      href={@href}
      class="relative inline-flex items-center px-4 py-2 text-sm font-medium text-zinc-600 dark:text-zinc-300 bg-zinc-50 dark:bg-zinc-800/50 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-lg transition-colors duration-200"
    >
      <svg :if={@direction == :prev} class="h-4 w-4 mr-1.5" viewBox="0 0 20 20" fill="currentColor">
        <path
          fill-rule="evenodd"
          d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z"
          clip-rule="evenodd"
        />
      </svg>
      {if @direction == :prev, do: gettext("Previous"), else: gettext("Next")}
      <svg :if={@direction == :next} class="h-4 w-4 ml-1.5" viewBox="0 0 20 20" fill="currentColor">
        <path
          fill-rule="evenodd"
          d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
          clip-rule="evenodd"
        />
      </svg>
    </a>
    """
  end
end
