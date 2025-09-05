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
    filtered_bookmarks = if String.trim(query) == "" do
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
    <div class="sm:px-8 mt-8 sm:mt-16">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <header class="max-w-2xl">
              <h1 class="text-4xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                <%= gettext("My Knowledge Base", lang: @locale) %>
              </h1>
              <p class="mt-6 text-base text-zinc-600 dark:text-zinc-400">
                <%= gettext("These are my favorite links from Pocket, organized by tags for easy browsing. My personal knowledge base covering programming, architecture, design, and more.", lang: @locale) %>
              </p>
            </header>

            <!-- Search and Filter Section -->
            <div class="mt-16 sm:mt-20">
              <div class="flex flex-col space-y-4 sm:flex-row sm:space-y-0 sm:space-x-4 sm:items-center">
                <div class="flex-1">
                  <label for="search" class="sr-only">Search bookmarks</label>
                  <div class="relative">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                      <svg class="h-5 w-5 text-zinc-400" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z" clip-rule="evenodd" />
                      </svg>
                    </div>
                    <input
                      id="search"
                      name="search"
                      type="search"
                      value={@search_query}
                      phx-change="search"
                      class="block w-full rounded-md border-0 bg-zinc-50 py-1.5 pl-10 pr-3 text-zinc-900 ring-1 ring-inset ring-zinc-300 placeholder:text-zinc-400 focus:ring-2 focus:ring-inset focus:ring-orange-600 dark:bg-zinc-900 dark:text-zinc-100 dark:ring-zinc-700 dark:placeholder:text-zinc-500 sm:text-sm sm:leading-6"
                      placeholder={gettext("Search bookmarks...", lang: @locale)}
                    />
                  </div>
                </div>
                <div class="flex-shrink-0">
                  <button
                    phx-click="toggle_view"
                    class={[
                      "inline-flex items-center rounded-md px-3 py-2 text-sm font-medium transition-colors",
                      if(@show_all_view,
                        do: "bg-orange-100 text-orange-800 hover:bg-orange-200 dark:bg-orange-500/20 dark:text-orange-300 dark:hover:bg-orange-500/30",
                        else: "bg-zinc-100 text-zinc-700 hover:bg-zinc-200 dark:bg-zinc-800 dark:text-zinc-300 dark:hover:bg-zinc-700"
                      )
                    ]}
                  >
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <%= if @show_all_view do %>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16" />
                      <% else %>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                      <% end %>
                    </svg>
                    <%= if @show_all_view do %>
                      <%= gettext("Compact View", lang: @locale) %>
                    <% else %>
                      <%= gettext("Detailed View", lang: @locale) %>
                    <% end %>
                  </button>
                </div>
              </div>

              <!-- Stats -->
              <div class="mt-8 grid grid-cols-1 gap-4 sm:grid-cols-3">
                <div class="bg-white dark:bg-zinc-800 overflow-hidden shadow rounded-lg">
                  <div class="p-5">
                    <div class="flex items-center">
                      <div class="flex-shrink-0">
                        <svg class="h-6 w-6 text-zinc-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 4V2a1 1 0 011-1h8a1 1 0 011 1v2h4a1 1 0 110 2h-1v14a2 2 0 01-2 2H6a2 2 0 01-2-2V6H3a1 1 0 110-2h4zM9 6v10a1 1 0 102 0V6a1 1 0 10-2 0z" />
                        </svg>
                      </div>
                      <div class="ml-5 w-0 flex-1">
                        <dl>
                          <dt class="text-sm font-medium text-zinc-500 dark:text-zinc-400 truncate">
                            <%= gettext("Total Bookmarks", lang: @locale) %>
                          </dt>
                          <dd class="text-lg font-medium text-zinc-900 dark:text-zinc-100">
                            <%= total_bookmarks_count(@bookmarks_by_tag_list) %>
                          </dd>
                        </dl>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="bg-white dark:bg-zinc-800 overflow-hidden shadow rounded-lg">
                  <div class="p-5">
                    <div class="flex items-center">
                      <div class="flex-shrink-0">
                        <svg class="h-6 w-6 text-zinc-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                        </svg>
                      </div>
                      <div class="ml-5 w-0 flex-1">
                        <dl>
                          <dt class="text-sm font-medium text-zinc-500 dark:text-zinc-400 truncate">
                            <%= gettext("Categories", lang: @locale) %>
                          </dt>
                          <dd class="text-lg font-medium text-zinc-900 dark:text-zinc-100">
                            <%= length(@bookmarks_by_tag_list) %>
                          </dd>
                        </dl>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="bg-white dark:bg-zinc-800 overflow-hidden shadow rounded-lg">
                  <div class="p-5">
                    <div class="flex items-center">
                      <div class="flex-shrink-0">
                        <svg class="h-6 w-6 text-zinc-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                        </svg>
                      </div>
                      <div class="ml-5 w-0 flex-1">
                        <dl>
                          <dt class="text-sm font-medium text-zinc-500 dark:text-zinc-400 truncate">
                            <%= gettext("Top Category", lang: @locale) %>
                          </dt>
                          <dd class="text-lg font-medium text-zinc-900 dark:text-zinc-100">
                            <%= get_top_category(@featured_tags) %>
                          </dd>
                        </dl>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Featured Tags -->
              <div class="mt-8">
                <h2 class="text-lg font-medium text-zinc-900 dark:text-zinc-100 mb-4">
                  <%= gettext("Popular Tags", lang: @locale) %>
                </h2>
                <div class="flex flex-wrap gap-2">
                  <button
                    :for={{tag, count} <- @featured_tags}
                    phx-click="filter_tag"
                    phx-value-tag={tag}
                    class={[
                      "inline-flex items-center rounded-full px-3 py-1.5 text-xs font-medium transition-colors",
                      if(@selected_tag == tag,
                        do: "bg-orange-100 text-orange-800 ring-1 ring-orange-600/20 dark:bg-orange-500/20 dark:text-orange-300",
                        else: "bg-zinc-100 text-zinc-700 hover:bg-zinc-200 dark:bg-zinc-800 dark:text-zinc-300 dark:hover:bg-zinc-700"
                      )
                    ]}
                  >
                    <%= String.replace(tag, "-", " ") |> String.capitalize() %>
                    <span class="ml-1.5 rounded-full bg-zinc-200 px-1.5 py-0.5 text-xs dark:bg-zinc-700">
                      <%= count %>
                    </span>
                  </button>
                </div>
              </div>
            </div>

            <!-- Bookmarks Content -->
            <div class="mt-16 sm:mt-20">
              <%= if @selected_tag do %>
                <div class="mb-8">
                  <div class="flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-zinc-800 dark:text-zinc-100">
                      <%= String.replace(@selected_tag, "-", " ") |> String.capitalize() %>
                    </h2>
                    <button
                      phx-click="filter_tag"
                      phx-value-tag={@selected_tag}
                      class="text-sm text-zinc-600 hover:text-zinc-800 dark:text-zinc-400 dark:hover:text-zinc-200"
                    >
                      <%= gettext("Show all", lang: @locale) %>
                    </button>
                  </div>
                </div>
                <.bookmarks_by_tag
                  bookmarks_by_tag={[{@selected_tag, Map.get(@bookmarks_by_tag_map, @selected_tag, [])}]}
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
