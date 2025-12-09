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
    <div class="space-y-16">
      <div :for={{tag, bookmarks} <- @bookmarks_by_tag} class="space-y-8" id={"tag-#{tag}"}>
        <!-- Tag Header -->
        <div class="flex items-center gap-4">
          <div class={"flex h-12 w-12 flex-shrink-0 items-center justify-center text-sm font-mono font-medium text-white #{Bookmarks.tag_color(tag)}"}>
            <%= Bookmarks.tag_initials(tag) %>
          </div>
          <div>
            <h2 class="text-xl font-display font-semibold text-ink">
              <%= String.replace(tag, "-", " ") |> String.capitalize() %>
            </h2>
            <p class="text-sm text-muted font-mono">
              <%= length(bookmarks) %> <%= if length(bookmarks) == 1, do: gettext("bookmark", lang: @locale), else: gettext("bookmarks", lang: @locale) %>
            </p>
          </div>
        </div>

        <!-- Bookmarks Grid -->
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <article
            :for={bookmark <- get_visible_bookmarks(bookmarks, tag, @expanded_tags, @items_per_page, @show_all_view)}
            class="group editorial-card hover:border-amber-500 transition-all duration-200"
          >
            <div class="flex flex-col h-full">
              <!-- Title & Domain -->
              <div class="flex items-start justify-between gap-3">
                <div class="min-w-0 flex-1">
                  <h3 class="text-base font-semibold text-ink group-hover:text-accent transition-colors duration-200 line-clamp-2">
                    <a href={bookmark.url} target="_blank" rel="noopener noreferrer">
                      <%= bookmark.title %>
                    </a>
                  </h3>
                  <p class="mt-1 text-xs font-mono text-muted">
                    <%= Bookmarks.get_domain(bookmark.url) %>
                  </p>
                </div>
                <div class="flex-shrink-0">
                  <svg class="h-4 w-4 text-muted group-hover:text-accent transition-colors duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" />
                  </svg>
                </div>
              </div>

              <!-- Tags & Date -->
              <div class="mt-auto pt-4 flex items-center justify-between">
                <div class="flex flex-wrap gap-1">
                  <span
                    :for={t <- Enum.take(bookmark.tags, 2)}
                    class="inline-flex items-center px-2 py-0.5 text-xs font-mono text-muted"
                    style="background: var(--paper-dark);"
                  >
                    <%= t %>
                  </span>
                  <span
                    :if={length(bookmark.tags) > 2}
                    class="inline-flex items-center px-2 py-0.5 text-xs font-mono text-muted"
                    style="background: var(--paper-dark);"
                  >
                    +<%= length(bookmark.tags) - 2 %>
                  </span>
                </div>
                <time class="text-xs font-mono text-muted" datetime={Bookmarks.format_date(bookmark.time_added)}>
                  <%= Bookmarks.format_date(bookmark.time_added) %>
                </time>
              </div>
            </div>
          </article>
        </div>

        <!-- Load More / Show Less Buttons -->
        <%= if show_load_more_button?(bookmarks, tag, @expanded_tags, @items_per_page, @show_all_view) do %>
          <div class="text-center">
            <button
              phx-click="load_more"
              phx-value-tag={tag}
              class="btn-secondary text-sm"
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
              class="text-sm text-muted hover:text-accent transition-colors duration-200"
            >
              <%= gettext("Show less", lang: @locale) %> ↑
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
