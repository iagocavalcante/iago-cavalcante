defmodule IagocavalcanteWeb.BookmarksLive do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Bookmarks

  def mount(_params, _session, socket) do
    bookmarks_by_tag_list = Bookmarks.bookmarks_by_tag()
    bookmarks_by_tag_map = Map.new(bookmarks_by_tag_list)
    featured_tags = Bookmarks.featured_tags()

    socket =
      socket
      |> assign(:bookmarks_by_tag_list, bookmarks_by_tag_list)
      |> assign(:bookmarks_by_tag_map, bookmarks_by_tag_map)
      |> assign(:featured_tags, featured_tags)
      |> assign(:selected_tag, nil)
      |> assign(:search_query, "")
      |> assign(:expanded_tags, MapSet.new())
      |> assign(:show_all_view, false)
      |> assign(:items_per_page, 12)

    {:ok, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    filtered_bookmarks =
      if String.trim(query) == "" do
        socket.assigns.bookmarks_by_tag_list
      else
        search_bookmarks(socket.assigns.bookmarks_by_tag_list, query)
      end

    {:noreply, assign(socket, search_query: query, bookmarks_by_tag_list: filtered_bookmarks)}
  end

  def handle_event("filter_tag", %{"tag" => tag}, socket) do
    selected_tag = if socket.assigns.selected_tag == tag, do: nil, else: tag
    {:noreply, assign(socket, :selected_tag, selected_tag)}
  end

  def handle_event("load_more", %{"tag" => tag}, socket) do
    expanded_tags = MapSet.put(socket.assigns.expanded_tags, tag)
    {:noreply, assign(socket, :expanded_tags, expanded_tags)}
  end

  def handle_event("show_less", %{"tag" => tag}, socket) do
    expanded_tags = MapSet.delete(socket.assigns.expanded_tags, tag)
    {:noreply, assign(socket, :expanded_tags, expanded_tags)}
  end

  def handle_event("toggle_view", _params, socket) do
    {:noreply, assign(socket, :show_all_view, !socket.assigns.show_all_view)}
  end

  defp search_bookmarks(bookmarks_by_tag_list, query) do
    query_lower = String.downcase(query)

    bookmarks_by_tag_list
    |> Enum.map(fn {tag, bookmarks} ->
      filtered_bookmarks =
        bookmarks
        |> Enum.filter(fn bookmark ->
          String.contains?(String.downcase(bookmark.title), query_lower) ||
            String.contains?(String.downcase(bookmark.url), query_lower) ||
            Enum.any?(bookmark.tags, &String.contains?(String.downcase(&1), query_lower))
        end)

      {tag, filtered_bookmarks}
    end)
    |> Enum.filter(fn {_tag, bookmarks} -> length(bookmarks) > 0 end)
  end

  defp total_bookmarks_count(bookmarks_by_tag_list) do
    bookmarks_by_tag_list
    |> Enum.map(fn {_tag, bookmarks} -> length(bookmarks) end)
    |> Enum.sum()
  end

  defp get_top_category(featured_tags) do
    case featured_tags do
      [{tag, _count} | _] -> String.replace(tag, "-", " ") |> String.capitalize()
      [] -> "N/A"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="sm:px-8 mt-12 sm:mt-20">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <header class="max-w-2xl">
              <!-- Section Label -->
              <div class="section-title mb-8">
                <span>{gettext("Collection", lang: @locale)}</span>
              </div>

              <h1 class="text-4xl sm:text-5xl font-display font-semibold tracking-tight text-ink">
                {gettext("My Knowledge Base", lang: @locale)}
              </h1>
              <p class="mt-6 text-base text-ink-light leading-relaxed">
                {gettext(
                  "These are my favorite links from Pocket, organized by tags for easy browsing. My personal knowledge base covering programming, architecture, design, and more.",
                  lang: @locale
                )}
              </p>
            </header>
            
    <!-- Search and Filter Section -->
            <div class="mt-16 sm:mt-20">
              <div class="flex flex-col space-y-4 sm:flex-row sm:space-y-0 sm:space-x-4 sm:items-center">
                <!-- Search Input -->
                <div class="flex-1">
                  <label for="search" class="sr-only">Search bookmarks</label>
                  <div class="relative">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4">
                      <svg class="h-5 w-5 text-muted" viewBox="0 0 20 20" fill="currentColor">
                        <path
                          fill-rule="evenodd"
                          d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
                          clip-rule="evenodd"
                        />
                      </svg>
                    </div>
                    <input
                      id="search"
                      name="search"
                      type="search"
                      value={@search_query}
                      phx-change="search"
                      class="editorial-input pl-12"
                      placeholder={gettext("Search bookmarks...", lang: @locale)}
                    />
                  </div>
                </div>
                
    <!-- View Toggle -->
                <div class="flex-shrink-0">
                  <button
                    phx-click="toggle_view"
                    class={[
                      "inline-flex items-center px-4 py-3 text-sm font-medium border transition-all duration-200",
                      if(@show_all_view,
                        do: "border-amber-500 text-amber-600 dark:text-amber-400",
                        else: "text-ink-light hover:border-amber-500"
                      )
                    ]}
                    style="background: var(--paper); border-color: var(--border);"
                  >
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <%= if @show_all_view do %>
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="1.5"
                          d="M4 6h16M4 10h16M4 14h16M4 18h16"
                        />
                      <% else %>
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="1.5"
                          d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                        />
                      <% end %>
                    </svg>
                    <%= if @show_all_view do %>
                      {gettext("Compact View", lang: @locale)}
                    <% else %>
                      {gettext("Detailed View", lang: @locale)}
                    <% end %>
                  </button>
                </div>
              </div>
              
    <!-- Stats Cards -->
              <div class="mt-10 grid grid-cols-1 gap-6 sm:grid-cols-3">
                <div class="editorial-card">
                  <div class="flex items-center gap-4">
                    <div
                      class="flex h-10 w-10 items-center justify-center"
                      style="background: var(--paper-dark);"
                    >
                      <svg
                        class="h-5 w-5 text-muted"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0111.186 0z"
                        />
                      </svg>
                    </div>
                    <div>
                      <p class="text-xs font-mono uppercase tracking-wider text-muted">
                        {gettext("Total Bookmarks", lang: @locale)}
                      </p>
                      <p class="text-2xl font-display font-semibold text-ink">
                        {total_bookmarks_count(@bookmarks_by_tag_list)}
                      </p>
                    </div>
                  </div>
                </div>

                <div class="editorial-card">
                  <div class="flex items-center gap-4">
                    <div
                      class="flex h-10 w-10 items-center justify-center"
                      style="background: var(--paper-dark);"
                    >
                      <svg
                        class="h-5 w-5 text-muted"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="M9.568 3H5.25A2.25 2.25 0 003 5.25v4.318c0 .597.237 1.17.659 1.591l9.581 9.581c.699.699 1.78.872 2.607.33a18.095 18.095 0 005.223-5.223c.542-.827.369-1.908-.33-2.607L11.16 3.66A2.25 2.25 0 009.568 3z"
                        />
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 6h.008v.008H6V6z" />
                      </svg>
                    </div>
                    <div>
                      <p class="text-xs font-mono uppercase tracking-wider text-muted">
                        {gettext("Categories", lang: @locale)}
                      </p>
                      <p class="text-2xl font-display font-semibold text-ink">
                        {length(@bookmarks_by_tag_list)}
                      </p>
                    </div>
                  </div>
                </div>

                <div class="editorial-card">
                  <div class="flex items-center gap-4">
                    <div
                      class="flex h-10 w-10 items-center justify-center"
                      style="background: var(--paper-dark);"
                    >
                      <svg
                        class="h-5 w-5 text-muted"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 013 19.875v-6.75zM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V8.625zM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V4.125z"
                        />
                      </svg>
                    </div>
                    <div>
                      <p class="text-xs font-mono uppercase tracking-wider text-muted">
                        {gettext("Top Category", lang: @locale)}
                      </p>
                      <p class="text-2xl font-display font-semibold text-ink">
                        {get_top_category(@featured_tags)}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
              
    <!-- Featured Tags -->
              <div class="mt-10">
                <h2 class="text-sm font-mono uppercase tracking-wider text-muted mb-4">
                  {gettext("Popular Tags", lang: @locale)}
                </h2>
                <div class="flex flex-wrap gap-2">
                  <button
                    :for={{tag, count} <- @featured_tags}
                    phx-click="filter_tag"
                    phx-value-tag={tag}
                    class={[
                      "editorial-tag transition-all duration-200",
                      if(@selected_tag == tag,
                        do: "bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300",
                        else: "hover:bg-stone-200 dark:hover:bg-stone-700"
                      )
                    ]}
                  >
                    {String.replace(tag, "-", " ") |> String.capitalize()}
                    <span class="ml-2 opacity-60">{count}</span>
                  </button>
                </div>
              </div>
            </div>
            
    <!-- Bookmarks Content -->
            <div class="mt-16 sm:mt-20">
              <%= if @selected_tag do %>
                <div class="mb-10">
                  <div class="flex items-center justify-between">
                    <h2 class="text-2xl font-display font-semibold text-ink">
                      {String.replace(@selected_tag, "-", " ") |> String.capitalize()}
                    </h2>
                    <button
                      phx-click="filter_tag"
                      phx-value-tag={@selected_tag}
                      class="text-sm text-muted hover:text-accent transition-colors duration-200"
                    >
                      {gettext("Show all", lang: @locale)} →
                    </button>
                  </div>
                </div>
                <.bookmarks_by_tag
                  bookmarks_by_tag={[
                    {@selected_tag, Map.get(@bookmarks_by_tag_map, @selected_tag, [])}
                  ]}
                  locale={@locale}
                  expanded_tags={@expanded_tags}
                  items_per_page={@items_per_page}
                  show_all_view={@show_all_view}
                />
              <% else %>
                <.bookmarks_by_tag
                  bookmarks_by_tag={Enum.take(@bookmarks_by_tag_list, 8)}
                  locale={@locale}
                  expanded_tags={@expanded_tags}
                  items_per_page={@items_per_page}
                  show_all_view={@show_all_view}
                />
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
