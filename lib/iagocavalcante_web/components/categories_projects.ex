defmodule IagocavalcanteWeb.CategoriesProjects do
  use Phoenix.Component

  attr :categories, :list,
    default: [
      %{
        name: "Open-source",
        slug: "open-source",
        description: "Open-source projects I've contributed to",
        projects: [
          %{
            name: "QTube",
            description: "A desktop app built with Electron and Vue.js using Quasar Framework",
            url: "https://qtube.iagocavalcante.com",
            image: "/images/projects/qtube.svg"
          },
          %{
            name: "Égua do artigo",
            description: "Project to bypass paywalls on Medium articles",
            url: "https://eguadoartigo.iagocavalcante.com",
            image: "/images/projects/eguadoartigo.svg"
          },
          %{
            name: "AbaetéFest",
            description: "App to help people find the best events and more in Abaeté, Brazil",
            url: "https://abaetefest.com.br/",
            image: "/images/projects/abaetefest.png"
          },
          %{
            name: "RN-Zendesk",
            description: "Bridge between Zendesk and React Native",
            url: "https://idopterlabs.github.io/rn-zendesk/",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "React-Native-Zoom-US-Bridge",
            description: "Bridge between Zoom and React Native",
            url: "https://www.npmjs.com/package/@iagocavalcante/react-native-zoom-us-bridge",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "Me Pague O que Dev",
            description:
              "Webapp to send anonymous messages to people who owe you money, built with Node and Vue.js using Lambda and Giphy API",
            url: "https://mepagueoquedev.iagocavalcante.com/",
            image: "/images/projects/mepagueoquedev.svg"
          },
          %{
            name: "Squash Hardcore",
            description: "Game built with Construct 2",
            url: "https://squash-hardcore.iagocavalcante.com/",
            image: "https://placehold.it/200x200"
          },
          %{
            name: "Personal Board v1",
            description:
              "A personal board to manage tasks and boards, built with Vue.js and Vuex",
            url: "https://personal-board-v1.iagocavalcante.com/",
            image: "/images/projects/personal-board-v1.png"
          }
        ]
      },
      %{
        name: "Client's projects",
        slug: "clients-projects",
        description: "Freelance projects I've worked on",
        projects: [
          %{
            name: "Gstack",
            description:
              "A newsletter platform for journalists and writers. Built with Next.js, MongoDB, NestJS, Heroku, Redis, Sendgrid, Stripe, and more.",
            url: "https://gstack.news",
            image: "/images/projects/gstack.png"
          },
          %{
            name: "Speech to text Analyzer",
            description:
              "Project built inside the Intelliway for a specific client, where I built a speech to text analyzer with RabitMQ, Aws Speech, Google Speech, CPQD Speech, NestJS, MongoDB and React",
            url: "https://www.intelliway.com.br/",
            image: "/images/projects/intelliway.webp"
          },
          %{
            name: "Sua conta BASA",
            description:
              "Built the frontend with Vue.js, we create a entire new webapp to open accounts",
            url: "https://sua-conta-basa.bancoamazonia.com.br/login?type=pf",
            image: "/images/projects/basa.png"
          },
          %{
            name: "HintClub/CartoLoL",
            description:
              "Fantasay League of Legends game built with VueJs, Django, Postgres, Redis, Docker, and more.",
            url: "https://cartolol.com.br/",
            image: "/images/projects/cartolol.png"
          },
          %{
            name: "HoverTrail",
            description:
              "A webapp to help people find the best trails to hike. Built with Remix, Tailwind and Postgres.",
            url: "https://hovertrail.fly.dev/",
            image: "/images/projects/hovertrail.png"
          },
          %{
            name: "Questões PRO",
            description:
              "Webapp is a platform where users can answer questions and get paid for it. Built with Vue, Postgres, Bootstrap, and AdonisJS.",
            url: "https://questoespro.com/",
            image: "https://placehold.it/200x200"
          },
          %{
            name: "Trail Club de Goiás",
            description:
              "Built a admin dashboard to manage infos and generate report using Rails and deployed to digital ocean, and App was built using React Native consuming the API built with Rails",
            url: "https://apps.apple.com/mu/app/trail-club-go-app/id1552081793?l=fr",
            image: "/images/projects/trailclub.png"
          }
        ]
      }
    ]

  def categories_projects(assigns) do
    render_categories(assigns)
  end

  defp render_categories(assigns) do
    ~H"""
    <div :for={category <- @categories} class="space-y-20">
      <div>
        <h2
          id="cursos"
          class="text-3xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 mt-10"
        >
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
              <a href={project.url} target="_blank">
                <span class="absolute -inset-y-6 -inset-x-4 z-20 sm:-inset-x-6 sm:rounded-2xl"></span>
                <span class="relative z-10"><%= project.name %></span>
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
              <span class="ml-2 break-all"><%= project.url %></span>
            </p>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
