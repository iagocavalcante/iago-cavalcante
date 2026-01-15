defmodule IagocavalcanteWeb.CategoriesProjects do
  use Phoenix.Component

  attr :categories, :list,
    default: [
      %{
        name: "My SaaS Products",
        slug: "saas-products",
        description: "Products I've built and maintain",
        projects: [
          %{
            name: "LeafTok",
            description:
              "AI-powered reading app that transforms books into interactive, bite-sized learning cards. Convert PDFs and EPUBs into swipeable cards with spaced repetition.",
            url: "https://leaftok.app",
            image: "/images/projects/leaftok.png"
          },
          %{
            name: "AgendFlow",
            description:
              "Sistema de Agendamento e Gestão de Serviços. Complete scheduling and service management platform for businesses.",
            url: "https://agendflow.com.br",
            image: "/images/projects/agendflow.ico"
          },
          %{
            name: "AbaetéFest App",
            description:
              "Mobile app to help people find the best events, restaurants, and attractions in Abaetetuba, Brazil.",
            url: "https://app.abaetefest.com.br",
            image: "/images/projects/abaetefest.png"
          }
        ]
      },
      %{
        name: "Open-source",
        slug: "open-source",
        description: "Open-source projects I've contributed to",
        projects: [
          %{
            name: "Oasis",
            description:
              "A hydration tracking app built with React Native and Expo. Features daily water intake tracking, streak system, reminders, and beautiful progress visualizations.",
            url: "https://apps.apple.com/br/app/oasis-drink-water/id6756798684?l=en-GB",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "Izi Queue",
            description:
              "A minimal, reliable, database-backed job queue for Node.js inspired by Oban. Supports PostgreSQL, SQLite, and MySQL with full TypeScript support.",
            url: "https://github.com/iagocavalcante/izi-queue",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "Termshare",
            description:
              "Share your terminal with anyone via QR code. Built with Bun, WebSockets, and PTY for real-time terminal streaming.",
            url: "https://termshare.fly.dev/",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "Age of Empires Clone",
            description:
              "A browser-based Age of Empires clone built with Three.js and TypeScript. Features 3D rendering and real-time strategy gameplay.",
            url: "https://age-of-empires-clone.fly.dev/",
            image: "/images/projects/gstack.webp"
          },
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
            image: "/images/projects/gstack.webp"
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
            name: "VRDEBank",
            description:
              "Digital banking platform. Worked on the web internet banking frontend and mobile applications.",
            url: "https://www.vrdebank.com/",
            image: "/images/projects/vrdebank.ico"
          },
          %{
            name: "Funqtion",
            description:
              "Full-stack development work building modern web applications and services.",
            url: "https://funqtion.co/",
            image: "/images/projects/funqtion.ico"
          },
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
            image: "/images/projects/gstack.webp"
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
    <div :for={category <- @categories} class="mb-20">
      <!-- Section Title -->
      <div class="section-title mb-8">
        <span id={category.slug}>{category.name}</span>
      </div>
      <!-- Projects Grid -->
      <ul role="list" class="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
        <li :for={project <- category.projects} class="group">
          <a
            href={project.url}
            target="_blank"
            class="block editorial-card h-full hover:border-amber-500 transition-all duration-200"
          >
            <!-- Project Icon -->
            <div
              class="flex h-12 w-12 items-center justify-center rounded-lg p-2 mb-4"
              style="background: var(--paper-dark);"
            >
              <img
                alt={project.name}
                src={project.image}
                decoding="async"
                class="h-full w-full object-contain"
                loading="lazy"
              />
            </div>
            <!-- Project Name -->
            <h3 class="text-base font-semibold text-ink group-hover:text-accent transition-colors duration-200">
              {project.name}
            </h3>
            <!-- Project Description -->
            <p class="mt-2 text-sm text-ink-light leading-relaxed">
              {project.description}
            </p>
            <!-- Link Indicator -->
            <div class="mt-4 flex items-center text-xs font-mono text-muted group-hover:text-accent transition-colors duration-200">
              <svg
                viewBox="0 0 24 24"
                aria-hidden="true"
                class="h-4 w-4 flex-none stroke-current"
                fill="none"
                stroke-width="1.5"
              >
                <path
                  d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
              </svg>
              <span class="ml-2 truncate">{URI.parse(project.url).host}</span>
            </div>
          </a>
        </li>
      </ul>
    </div>
    """
  end
end
