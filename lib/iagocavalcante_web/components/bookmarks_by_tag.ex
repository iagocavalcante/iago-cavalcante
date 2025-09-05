defmodule IagocavalcanteWeb.Components.BookmarksByTag do
  use Phoenix.Component
  use Gettext, backend: IagocavalcanteWeb.Gettext

  alias Iagocavalcante.Bookmarks

  attr :bookmarks_by_tag, :list, required: true
  attr :locale, :string, default: "en"
  attr :expanded_tags, :any, default: MapSet.new()
  attr :items_per_page, :integer, default: 12
  attr :show_all_view, :boolean, default: false

  def bookmarks_by_tag(assigns) do
    ~H"""
    <div class="space-y-12">
      <div :for={{tag, bookmarks} <- @bookmarks_by_tag} class="space-y-6" id={"tag-#{tag}"}>
        <div class="flex items-center space-x-3">
          <div class={"flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg text-sm font-medium text-white #{Bookmarks.tag_color(tag)}"}>
            <%= Bookmarks.tag_initials(tag) %>
          </div>
          <div>
            <h2 class="text-2xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100">
              <%= String.replace(tag, "-", " ") |> String.capitalize() %>
            </h2>
            <p class="text-sm text-zinc-600 dark:text-zinc-400">
              <%= length(bookmarks) %> <%= if length(bookmarks) == 1, do: gettext("bookmark", lang: @locale), else: gettext("bookmarks", lang: @locale) %>
            </p>
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <article
            :for={bookmark <- get_visible_bookmarks(bookmarks, tag, @expanded_tags, @items_per_page, @show_all_view)}
            class="group relative flex flex-col overflow-hidden rounded-lg border border-zinc-200 bg-white shadow-sm transition-shadow hover:shadow-md dark:border-zinc-700 dark:bg-zinc-800"
          >
            <div class="flex flex-1 flex-col p-6">
              <div class="flex items-start justify-between">
                <div class="min-w-0 flex-1">
                  <h3 class="text-base font-medium text-zinc-900 dark:text-zinc-100 line-clamp-2">
                    <a href={bookmark.url} target="_blank" rel="noopener noreferrer" class="hover:underline">
                      <%= bookmark.title %>
                    </a>
                  </h3>
                  <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                    <%= Bookmarks.get_domain(bookmark.url) %>
                  </p>
                </div>
                <div class="ml-3 flex-shrink-0">
                  <svg class="h-5 w-5 text-zinc-400 group-hover:text-zinc-600 dark:text-zinc-500 dark:group-hover:text-zinc-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                  </svg>
                </div>
              </div>

              <div class="mt-4 flex items-center justify-between">
                <div class="flex flex-wrap gap-1">
                  <span :for={tag <- Enum.take(bookmark.tags, 3)} class="inline-flex items-center rounded-md bg-zinc-100 px-2 py-1 text-xs font-medium text-zinc-800 dark:bg-zinc-700 dark:text-zinc-200">
                    <%= tag %>
                  </span>
                  <span :if={length(bookmark.tags) > 3} class="inline-flex items-center rounded-md bg-zinc-100 px-2 py-1 text-xs font-medium text-zinc-600 dark:bg-zinc-700 dark:text-zinc-400">
                    +<%= length(bookmark.tags) - 3 %>
                  </span>
                </div>
                <time class="text-xs text-zinc-500 dark:text-zinc-400" datetime={Bookmarks.format_date(bookmark.time_added)}>
                  <%= Bookmarks.format_date(bookmark.time_added) %>
                </time>
              </div>
            </div>
          </article>
        </div>

        <%= if show_load_more_button?(bookmarks, tag, @expanded_tags, @items_per_page, @show_all_view) do %>
          <div class="text-center space-y-2">
            <button
              phx-click="load_more"
              phx-value-tag={tag}
              class="inline-flex items-center rounded-md bg-zinc-100 px-4 py-2 text-sm font-medium text-zinc-700 hover:bg-zinc-200 dark:bg-zinc-700 dark:text-zinc-200 dark:hover:bg-zinc-600"
            >
              <%= gettext("Show %{count} more", count: get_remaining_count(bookmarks, tag, @expanded_tags, @items_per_page), lang: @locale) %>
            </button>
          </div>
        <% end %>

        <%= if show_less_button?(bookmarks, tag, @expanded_tags, @items_per_page) do %>
          <div class="text-center">
            <button
              phx-click="show_less"
              phx-value-tag={tag}
              class="inline-flex items-center rounded-md bg-zinc-50 px-4 py-2 text-sm font-medium text-zinc-600 hover:bg-zinc-100 dark:bg-zinc-800 dark:text-zinc-300 dark:hover:bg-zinc-700"
            >
              <%= gettext("Show less", lang: @locale) %>
            </button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Helper functions for bookmark visibility logic
  defp get_visible_bookmarks(bookmarks, tag, expanded_tags, items_per_page, show_all_view) do
    cond do
      show_all_view -> bookmarks
      MapSet.member?(expanded_tags, tag) -> bookmarks
      true -> Enum.take(bookmarks, items_per_page)
    end
  end

  defp show_load_more_button?(bookmarks, tag, expanded_tags, items_per_page, show_all_view) do
    !show_all_view &&
    !MapSet.member?(expanded_tags, tag) &&
    length(bookmarks) > items_per_page
  end

  defp show_less_button?(bookmarks, tag, expanded_tags, items_per_page) do
    MapSet.member?(expanded_tags, tag) &&
    length(bookmarks) > items_per_page
  end

  defp get_remaining_count(bookmarks, tag, expanded_tags, items_per_page) do
    if MapSet.member?(expanded_tags, tag) do
      0
    else
      max(0, length(bookmarks) - items_per_page)
    end
  end
end
