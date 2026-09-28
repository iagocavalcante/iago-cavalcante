defmodule IagocavalcanteWeb.CategoriesProjects do
  use Phoenix.Component

  use Gettext, backend: IagocavalcanteWeb.Gettext

  # Built at render time, not as an attr default, so gettext picks up the
  # request locale.
  defp categories do
    [
      %{
        name: gettext("Apps"),
        slug: "apps",
        projects: [
          %{
            name: "MiseSnag",
            description:
              gettext(
                "Turns TikTok, Instagram and YouTube recipe videos into a recipe and a grocery list with AI. Free on iPhone and Android."
              ),
            url: "https://misesnag.app",
            image: "/images/projects/misesnag.png",
            stores: [
              %{name: "App Store", url: "https://apps.apple.com/app/id6795595576"},
              %{
                name: "Google Play",
                url: "https://play.google.com/store/apps/details?id=com.iagocavalcante.misesnag"
              }
            ]
          },
          %{
            name: "Fitlock",
            description:
              gettext(
                "Earn your screen time: distracting apps stay locked until you do bodyweight reps, counted on-device by the camera."
              ),
            url: "https://fitlock.iagocavalcante.com",
            image: "/images/projects/fitlock.png",
            stores: [
              %{name: "App Store", url: "https://apps.apple.com/app/id6812144123"},
              %{
                name: "Google Play",
                url: "https://play.google.com/store/apps/details?id=com.iagocavalcante.fitlock"
              }
            ]
          },
          %{
            name: "Trainer Gym AI",
            description:
              gettext(
                "AI personal trainer that generates personalized workout plans for beginners who don't know what to do at the gym. One-time price, no subscription."
              ),
            url: "https://trainergymai.app",
            image: "/images/projects/trainergymai.png",
            stores: [
              %{name: "App Store", url: "https://apps.apple.com/app/id6670231666"},
              %{
                name: "Google Play",
                url:
                  "https://play.google.com/store/apps/details?id=com.iagocavalcante.trainergymai"
              }
            ]
          },
          %{
            name: "LeafTok",
            description:
              gettext(
                "TikTok-style book reader. Turns any EPUB or PDF into swipeable cards, with on-device narration, reading streaks and book clubs."
              ),
            url: "https://leaftok.app",
            image: "/images/projects/leaftok.png",
            stores: [
              %{name: "App Store", url: "https://apps.apple.com/app/id6748622950"},
              %{
                name: "Google Play",
                url: "https://play.google.com/store/apps/details?id=com.iagocavalcante.leaftok"
              }
            ]
          },
          %{
            name: "EF Nutry",
            description:
              gettext(
                "Meal plans built on Brazilian food: AI drafts the plan and a nutritionist reviews and approves it."
              ),
            url: "https://www.efnutry.com",
            image: "/images/projects/efnutry.png"
          },
          %{
            name: "Oasis",
            description:
              gettext(
                "A hydration tracking app built with React Native and Expo. Features daily water intake tracking, streak system, reminders, and beautiful progress visualizations."
              ),
            url: "https://apps.apple.com/app/id6756798684",
            image: "/images/projects/oasis.png",
            stores: [
              %{name: "App Store", url: "https://apps.apple.com/app/id6756798684"},
              %{
                name: "Google Play",
                url: "https://play.google.com/store/apps/details?id=com.iagocavalcante.Oasis"
              }
            ]
          }
        ]
      },
      %{
        name: gettext("My SaaS Products"),
        slug: "saas-products",
        projects: [
          %{
            name: "AgendFlow",
            description:
              gettext("Complete scheduling and service management platform for businesses."),
            url: "https://agendflow.com.br",
            image: "/images/projects/agendflow.ico"
          },
          %{
            name: "AbaetéFest App",
            description:
              gettext(
                "Mobile app to help people find the best events, restaurants, and attractions in Abaetetuba, Brazil."
              ),
            url: "https://app.abaetefest.com.br",
            image: "/images/projects/abaetefest.png"
          }
        ]
      },
      %{
        name: gettext("Open-source"),
        slug: "open-source",
        projects: [
          %{
            name: "Claude Turbo Search",
            description:
              gettext(
                "Optimized file search and semantic indexing for large codebases in Claude Code. Combines ripgrep, fzf, and QMD semantic search to save 60-80% tokens on exploration."
              ),
            url: "https://github.com/iagocavalcante/claude-turbo-search",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "Izi Queue",
            description:
              gettext(
                "A minimal, reliable, database-backed job queue for Node.js inspired by Oban. Supports PostgreSQL, SQLite, and MySQL with full TypeScript support."
              ),
            url: "https://github.com/iagocavalcante/izi-queue",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "Termshare",
            description:
              gettext(
                "Share your terminal with anyone via QR code. Built with Bun, WebSockets, and PTY for real-time terminal streaming."
              ),
            url: "https://termshare.fly.dev/",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "Age of Empires Clone",
            description:
              gettext(
                "A browser-based Age of Empires clone built with Three.js and TypeScript. Features 3D rendering and real-time strategy gameplay."
              ),
            url: "https://age-of-empires-clone.fly.dev/",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "QTube",
            description:
              gettext("A desktop app built with Electron and Vue.js using Quasar Framework"),
            url: "https://qtube.iagocavalcante.com",
            image: "/images/projects/qtube.svg"
          },
          %{
            name: "Égua do artigo",
            description: gettext("Project to bypass paywalls on Medium articles"),
            url: "https://eguadoartigo.iagocavalcante.com",
            image: "/images/projects/eguadoartigo.svg"
          },
          %{
            name: "RN-Zendesk",
            description: gettext("Bridge between Zendesk and React Native"),
            url: "https://idopterlabs.github.io/rn-zendesk/",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "React-Native-Zoom-US-Bridge",
            description: gettext("Bridge between Zoom and React Native"),
            url: "https://www.npmjs.com/package/@iagocavalcante/react-native-zoom-us-bridge",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "Me Pague O que Dev",
            description:
              gettext(
                "Webapp to send anonymous messages to people who owe you money, built with Node and Vue.js using Lambda and Giphy API"
              ),
            url: "https://mepagueoquedev.iagocavalcante.com/",
            image: "/images/projects/mepagueoquedev.svg"
          },
          %{
            name: "Squash Hardcore",
            description: gettext("Game built with Construct 2"),
            url: "https://squash-hardcore.iagocavalcante.com/",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "Personal Board v1",
            description:
              gettext("A personal board to manage tasks and boards, built with Vue.js and Vuex"),
            url: "https://personal-board-v1.iagocavalcante.com/",
            image: "/images/projects/personal-board-v1.png"
          }
        ]
      },
      %{
        name: gettext("Client's projects"),
        slug: "clients-projects",
        projects: [
          %{
            name: "VRDEBank",
            description:
              gettext(
                "Digital banking platform. Worked on the web internet banking frontend and mobile applications."
              ),
            url: "https://www.vrdebank.com/",
            image: "/images/projects/vrdebank.ico"
          },
          %{
            name: "Funqtion",
            description:
              gettext(
                "Full-stack development work building modern web applications and services."
              ),
            url: "https://funqtion.co/",
            image: "/images/projects/funqtion.ico"
          },
          %{
            name: "Gstack",
            description:
              gettext(
                "A newsletter platform for journalists and writers. Built with Next.js, MongoDB, NestJS, Heroku, Redis, Sendgrid, Stripe, and more."
              ),
            url: "https://gstack.news",
            image: "/images/projects/gstack.png"
          },
          %{
            name: "Speech to text Analyzer",
            description:
              gettext(
                "Project built inside the Intelliway for a specific client, where I built a speech to text analyzer with RabitMQ, Aws Speech, Google Speech, CPQD Speech, NestJS, MongoDB and React"
              ),
            url: "https://www.intelliway.com.br/",
            image: "/images/projects/intelliway.webp"
          },
          %{
            name: "Sua conta BASA",
            description:
              gettext(
                "Built the frontend with Vue.js, we create a entire new webapp to open accounts"
              ),
            url: "https://sua-conta-basa.bancoamazonia.com.br/login?type=pf",
            image: "/images/projects/basa.png"
          },
          %{
            name: "HintClub/CartoLoL",
            description:
              gettext(
                "Fantasay League of Legends game built with VueJs, Django, Postgres, Redis, Docker, and more."
              ),
            url: "https://cartolol.com.br/",
            image: "/images/projects/cartolol.png"
          },
          %{
            name: "HoverTrail",
            description:
              gettext(
                "A webapp to help people find the best trails to hike. Built with Remix, Tailwind and Postgres."
              ),
            url: "https://hovertrail.fly.dev/",
            image: "/images/projects/hovertrail.png"
          },
          %{
            name: "Questões PRO",
            description:
              gettext(
                "Webapp is a platform where users can answer questions and get paid for it. Built with Vue, Postgres, Bootstrap, and AdonisJS."
              ),
            url: "https://questoespro.com/",
            image: "/images/projects/gstack.webp"
          },
          %{
            name: "Trail Club de Goiás",
            description:
              gettext(
                "Built a admin dashboard to manage infos and generate report using Rails and deployed to digital ocean, and App was built using React Native consuming the API built with Rails"
              ),
            url: "https://apps.apple.com/mu/app/trail-club-go-app/id1552081793?l=fr",
            image: "/images/projects/trailclub.png"
          }
        ]
      }
    ]
  end

  def categories_projects(assigns) do
    assigns = assign(assigns, :categories, categories())

    ~H"""
    <div :for={category <- @categories} class="mb-20">
      <!-- Section Title -->
      <div class="section-title mb-8">
        <span id={category.slug}>{category.name}</span>
      </div>
      <!-- Projects Grid -->
      <ul role="list" class="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
        <li
          :for={project <- category.projects}
          class="group editorial-card flex flex-col hover:border-amber-500 transition-all duration-200"
        >
          <a href={project.url} target="_blank" rel="noopener" class="block flex-1">
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
          <!-- Download Links -->
          <div :if={project[:stores]} class="mt-4 flex flex-wrap gap-2">
            <a
              :for={store <- project.stores}
              href={store.url}
              target="_blank"
              rel="noopener"
              aria-label={
                gettext("Download %{app} on %{store}", app: project.name, store: store.name)
              }
              class="rounded-full border px-3 py-1 text-xs font-mono text-ink-light hover:border-amber-500 hover:text-accent transition-colors duration-200"
            >
              {store.name}
            </a>
          </div>
        </li>
      </ul>
    </div>
    """
  end
end
