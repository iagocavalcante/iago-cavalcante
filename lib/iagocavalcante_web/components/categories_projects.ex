defmodule IagocavalcanteWeb.CategoriesProjects do
  use IagocavalcanteWeb, :live_component

  import IagocavalcanteWeb.Gettext
  alias IagocavalcanteWeb.ProjectsList

  attr :categories, :list,
    default: [
      %{
        name: "Cursos",
        slug: "cursos",
        description: "Cursos que eu já ministrei",
        projects: [
          %{
            name: "Planetaria",
            description: "A simple and fast 2D game engine for Unity",
            url: "http://planetaria.tech",
            image: "/_next/static/media/planetaria.ecd81ade.svg"
          },
          %{
            name: "Iago Cavalcante",
            description: "My personal website",
            url: "",
            image: "/_next/static/media/iagocavalcante.1b0e1b1a.svg"
          },
          %{
            name: "Elixir Brasil",
            description: "A Brazilian community for Elixir",
            url: "https://elixirbrasil.com",
            image: "/_next/static/media/elixirbrasil.1b0e1b1a.svg"
          }
        ]
      },
      %{
        name: "Palestras",
        slug: "palestras",
        description: "Palestras que eu já ministrei",
        projects: [
          %{
            name: "Planetaria",
            description: "A simple and fast 2D game engine for Unity",
            url: "http://planetaria.tech",
            image: "/_next/static/media/planetaria.ecd81ade.svg"
          },
          %{
            name: "Iago Cavalcante",
            description: "My personal website",
            url: "",
            image: "/_next/static/media/iagocavalcante.1b0e1b1a.svg"
          },
          %{
            name: "Elixir Brasil",
            description: "A Brazilian community for Elixir",
            url: "https://elixirbrasil.com",
            image: "/_next/static/media/elixirbrasil.1b0e1b1a.svg"
          }
        ]
      },
      %{
        name: "Workshops",
        slug: "workshops",
        description: "Workshops que eu já ministrei",
        projects: [
          %{
            name: "Planetaria",
            description: "A simple and fast 2D game engine for Unity",
            url: "http://planetaria.tech",
            image: "/_next/static/media/planetaria.ecd81ade.svg"
          },
          %{
            name: "Iago Cavalcante",
            description: "My personal website",
            url: "",
            image: "/_next/static/media/iagocavalcante.1b0e1b1a.svg"
          },
          %{
            name: "Elixir Brasil",
            description: "A Brazilian community for Elixir",
            url: "https://elixirbrasil.com",
            image: "/_next/static/media/elixirbrasil.1b0e1b1a.svg"
          }
        ]
      }
    ]

  def categories_projects(assigns) do
    ~H"""
    <div :for={category <- @categories} class="space-y-20">
      <div>
        <h2 id="cursos" class="text-3xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 mt-10">
          <a href={"##{category.slug}"}><%= category.name %></a>
        </h2>
        <ul role="list" class="grid grid-cols-1 gap-x-12 gap-y-16 sm:grid-cols-2 lg:grid-cols-3 mt-10">
          <li :for={project <- category.projects} class="group relative flex flex-col items-start">
            <div class="relative z-10 flex h-12 w-12 items-center justify-center rounded-full bg-white shadow-md shadow-zinc-800/5 ring-1 ring-zinc-900/5 dark:border dark:border-zinc-700/50 dark:bg-zinc-800 dark:ring-0">
              <img
                alt=""
                src={project.image}
                decoding="async"
                data-nimg="1"
                class="h-8 w-8"
                loading="lazy"
                style="color: transparent;"
                width="32"
                height="32"
              />
            </div>
            <h2 class="mt-6 text-base font-semibold text-zinc-800 dark:text-zinc-100">
              <div class="absolute -inset-y-6 -inset-x-4 z-0 scale-95 bg-zinc-50 opacity-0 transition group-hover:scale-100 group-hover:opacity-100 dark:bg-zinc-800/50 sm:-inset-x-6 sm:rounded-2xl">
              </div>
              <a href={project.url}>
                <span class="absolute -inset-y-6 -inset-x-4 z-20 sm:-inset-x-6 sm:rounded-2xl"></span><span class="relative z-10">Planetaria</span>
              </a>
            </h2>
            <p class="relative z-10 mt-2 text-sm text-zinc-600 dark:text-zinc-400">
              <%= project.description %>
            </p>
            <p class="relative z-10 mt-6 flex text-sm font-medium text-zinc-400 transition group-hover:text-teal-500 dark:text-zinc-200">
              <svg viewBox="0 0 24 24" aria-hidden="true" class="h-6 w-6 flex-none">
                <path
                  d="M15.712 11.823a.75.75 0 1 0 1.06 1.06l-1.06-1.06Zm-4.95 1.768a.75.75 0 0 0 1.06-1.06l-1.06 1.06Zm-2.475-1.414a.75.75 0 1 0-1.06-1.06l1.06 1.06Zm4.95-1.768a.75.75 0 1 0-1.06 1.06l1.06-1.06Zm3.359.53-.884.884 1.06 1.06.885-.883-1.061-1.06Zm-4.95-2.12 1.414-1.415L12 6.344l-1.415 1.413 1.061 1.061Zm0 3.535a2.5 2.5 0 0 1 0-3.536l-1.06-1.06a4 4 0 0 0 0 5.656l1.06-1.06Zm4.95-4.95a2.5 2.5 0 0 1 0 3.535L17.656 12a4 4 0 0 0 0-5.657l-1.06 1.06Zm1.06-1.06a4 4 0 0 0-5.656 0l1.06 1.06a2.5 2.5 0 0 1 3.536 0l1.06-1.06Zm-7.07 7.07.176.177 1.06-1.06-.176-.177-1.06 1.06Zm-3.183-.353.884-.884-1.06-1.06-.884.883 1.06 1.06Zm4.95 2.121-1.414 1.414 1.06 1.06 1.415-1.413-1.06-1.061Zm0-3.536a2.5 2.5 0 0 1 0 3.536l1.06 1.06a4 4 0 0 0 0-5.656l-1.06 1.06Zm-4.95 4.95a2.5 2.5 0 0 1 0-3.535L6.344 12a4 4 0 0 0 0 5.656l1.06-1.06Zm-1.06 1.06a4 4 0 0 0 5.657 0l-1.061-1.06a2.5 2.5 0 0 1-3.535 0l-1.061 1.06Zm7.07-7.07-.176-.177-1.06 1.06.176.178 1.06-1.061Z"
                  fill="currentColor"
                >
                </path>
              </svg>
              <span class="ml-2"><%= project.url %></span>
            </p>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
