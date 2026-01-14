defmodule IagocavalcanteWeb.ArticlesLive.Index do
  use IagocavalcanteWeb, :live_view

  alias Iagocavalcante.Blog

  @per_page 10

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    page = parse_page(params["page"])

    pagination =
      Blog.paginate_posts_by_locale(socket.assigns.locale, page: page, per_page: @per_page)

    {:noreply,
     socket
     |> assign(:page_title, gettext("Articles"))
     |> assign(:pagination, pagination)}
  end

  defp parse_page(nil), do: 1

  defp parse_page(page) when is_binary(page) do
    case Integer.parse(page) do
      {num, ""} when num > 0 -> num
      _ -> 1
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
                {gettext(
                  "I write about software in general, and now I want to talk more about hardware and IoT.",
                  lang: @locale
                )}
              </h1>
              <p class="mt-6 text-base text-zinc-600 dark:text-zinc-400">
                {gettext(
                  "Here will be centralized all the old and current posts and thoughts, with tips and some solutions that I have implemented throughout my career.",
                  lang: @locale
                )}
              </p>
            </header>
            <div class="mt-16 sm:mt-20">
              <div class="md:border-l md:border-zinc-100 md:pl-6 md:dark:border-zinc-700/40">
                <div class="flex max-w-3xl flex-col space-y-16">
                  <.articles_list articles={@pagination.posts} locale={@locale} />
                </div>
              </div>

              <.pagination
                page={@pagination.page}
                total_pages={@pagination.total_pages}
                has_prev={@pagination.has_prev}
                has_next={@pagination.has_next}
                total_posts={@pagination.total_posts}
                path="/articles"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
