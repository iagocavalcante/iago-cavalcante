defmodule IagocavalcanteWeb.Posts do
  use Phoenix.Component
  import IagocavalcanteWeb.Gettext

  attr :articles, :list,
    default: [
      %{
        title: "Rewriting the Cosmos Kernel in Rust",
        description: "A step-by-step guide on how to rewrite the Cosmos Kernel in Rust",
        inserted_at: "2021-09-01",
        tags: ["rust", "cosmos", "kernel", "osdev"],
        image: "/images/articles/rewriting-the-cosmos-kernel-in-rust/cover.png",
        image_alt: "A screenshot of the Cosmos Kernel running on QEMU",
        url: "/articles/rewriting-the-cosmos-kernel-in-rust"
      },
      %{
        title: "Building a Rust Kernel",
        description: "A step-by-step guide on how to build a Rust Kernel",
        inserted_at: "2021-08-01",
        tags: ["rust", "kernel", "osdev"],
        image: "/images/articles/building-a-rust-kernel/cover.png",
        image_alt: "A screenshot of the Cosmos Kernel running on QEMU",
        url: "/articles/building-a-rust-kernel"
      },
      %{
        title: "Building a Rust Kernel",
        description: "A step-by-step guide on how to build a Rust Kernel",
        inserted_at: "2021-08-01",
        tags: ["rust", "kernel", "osdev"],
        image: "/images/articles/building-a-rust-kernel/cover.png",
        image_alt: "A screenshot of the Cosmos Kernel running on QEMU",
        url: "/articles/building-a-rust-kernel"
      }
    ]

  def posts(assigns) do
    ~H"""
    <article :for={article <- @articles} class="group relative flex flex-col items-start">
      <h2 class="text-base font-semibold tracking-tight text-zinc-800 dark:text-zinc-100">
        <div class="absolute -inset-y-6 -inset-x-4 z-0 scale-95 bg-zinc-50 opacity-0 transition group-hover:scale-100 group-hover:opacity-100 dark:bg-zinc-800/50 sm:-inset-x-6 sm:rounded-2xl">
        </div>
        <a href={"/articles/#{article.slug}"}>
          <span class="absolute -inset-y-6 -inset-x-4 z-20 sm:-inset-x-6 sm:rounded-2xl"></span>
          <span class="relative z-10"><%= article.title %></span>
        </a>
      </h2>
      <time
        class="relative z-10 order-first mb-3 flex items-center text-sm text-zinc-400 dark:text-zinc-500 pl-3.5"
        datetime="2022-07-14"
      >
        <span class="absolute inset-y-0 left-0 flex items-center" aria-hidden="true">
          <span class="h-4 w-0.5 rounded-full bg-zinc-200 dark:bg-zinc-500"></span>
        </span>
        <%= format_date(article.inserted_at) %>
      </time>
      <p class="relative z-10 mt-2 text-sm text-zinc-600 dark:text-zinc-400">
        <%= article.description %>
      </p>
      <div
        aria-hidden="true"
        class="relative z-10 mt-4 flex items-center text-sm font-medium text-teal-500"
      >
        <%= gettext("Read article", lang: @locale) %><svg
          viewBox="0 0 16 16"
          fill="none"
          aria-hidden="true"
          class="ml-1 h-4 w-4 stroke-current"
        ><path
            d="M6.75 5.75 9.25 8l-2.5 2.25"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          ></path></svg>
      </div>
    </article>
    """
  end

  defp format_date(date) do
    date |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_date()
  end
end
