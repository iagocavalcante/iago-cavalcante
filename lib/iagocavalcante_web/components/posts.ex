defmodule IagocavalcanteWeb.Posts do
  use Phoenix.Component
  use Gettext, backend: IagocavalcanteWeb.Gettext

  attr :locale, :string, default: "en"
  attr :articles, :list

  def posts(assigns) do
    ~H"""
    <article :for={article <- @articles} class="article-card">
      <!-- Date -->
      <time
        class="article-meta mb-2"
        datetime={article.date}
      >
        {article.date}
      </time>
      
    <!-- Title -->
      <h2 class="article-title">
        <a href={"/articles/#{article.id}"} class="group">
          <span class="absolute -inset-y-4 -inset-x-4 z-10"></span>
          {article.title}
        </a>
      </h2>
      
    <!-- Description -->
      <p class="article-excerpt">
        {article.description}
      </p>
      
    <!-- Read More Link -->
      <div class="mt-4 flex items-center text-sm font-medium text-accent">
        {gettext("Read article", lang: @locale)}
        <svg
          viewBox="0 0 16 16"
          fill="none"
          aria-hidden="true"
          class="ml-1.5 h-4 w-4 stroke-current"
        >
          <path
            d="M6.75 5.75 9.25 8l-2.5 2.25"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </div>
    </article>
    """
  end
end
