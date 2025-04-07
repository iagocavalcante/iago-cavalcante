defmodule IagocavalcanteWeb.CategoriesUses do
  use Phoenix.Component

  import IagocavalcanteWeb.Gettext

  attr :categories, :list,
    default: [
      %{
        name: "Workstation",
        has_image: true,
        uses: [
          %{
            name: "MacBook Air, M3 16GB RAM (2024)",
            description:
              "Satisfy all my needs for work and personal projects. I use it for web development, mobile development, backend development, and even for video editing."
          },
          %{
            name: "Monitor Gamer LG Ultrawide 29UM69G",
            description:
              "When I buy this monitor, it was the best monitor for developers. It has a 21:9 aspect ratio, which is perfect for coding. It also has a 75Hz refresh rate, which is perfect for video editing."
          },
          %{
            name: "Ergonomic Support - F80N ELG ",
            description:
              "I use this support to keep my back straight and my neck in a good position. It's very comfortable and it's very easy to use with my monitor and desk."
          },
          %{
            name: "Keyboard - Keychron K2",
            description:
              "I use this keyboard for coding and video editing. It has a very good typing experience."
          },
          %{
            name: "Mouse - Razer Basilisk V2",
            description:
              "I decide to buy this because I want to make almost all my peripherals being bluetooth."
          },
          %{
            name: "Chair - FlexForm Uni Pro",
            description:
              "This is a medium budget chair, but it's very comfortable. I use it for 5 hours a day and it's very good."
          },
          %{
            name: "AirPods Pro",
            description:
              "I use this for listening to music, and watching videos. It's very comfortable and it's very easy to use."
          },
          %{
            name: "Secundary Headphones - Senheiser HD 4.50 BTNC",
            description:
              "I use this for listening to music, and watching videos. It's very comfortable and it's very easy to use."
          },
          %{
            name: "Blue Yeti Pro Microphone",
            description:
              "I use this for recording videos, podcasts and meetings. Very powerful and easy to use."
          }
        ]
      },
      %{
        name: "Development Environment",
        has_image: false,
        uses: [
          %{
            name: "Zed Editor",
            description: "My favorite code editor at this point. It's very powerful and it's very easy to use."
          },
          %{
            name: "Rio terminal",
            description: "My favorite terminal and session manager."
          },
          %{
            name: "Spectacle",
            description: "My favorite window manager. Use to manage window size and position."
          },
          %{
            name: "Cleanshot X",
            description: "My favorite screenshot tool and screen recorder."
          },
          %{
            name: "Da Vinci Resolve",
            description: "My favorite video editor and its free."
          },
          %{
            name: "Figma",
            description: "My favorite design tool."
          },
          %{
            name: "Obsidian",
            description: "My favorite note taking app."
          },
          %{
            name: "1password",
            description: "My favorite password manager."
          }
        ]
      }
    ]

  def categories_uses(assigns) do
    ~H"""
    <section
      :for={category <- @categories}
      aria-labelledby=":r9:"
      class="md:border-l md:border-zinc-100 md:pl-6 md:dark:border-zinc-700/40"
    >
      <%= if category.has_image do %>
        <img
          src={"/images/uses/#{String.downcase(category.name)}.jpeg"}
          class="w-full h-96 object-cover mb-8 rounded-lg"
        />
      <% end %>
      <div class="grid max-w-3xl grid-cols-1 items-baseline gap-y-8 md:grid-cols-4">
        <h2 id=":r9:" class="text-sm font-semibold text-zinc-800 dark:text-zinc-100">
          <%= category.name %>
        </h2>
        <div class="md:col-span-3">
          <ul role="list" class="space-y-12">
            <li :for={used <- category.uses} class="group relative flex flex-col items-start">
              <h3 class="text-base font-semibold tracking-tight text-zinc-800 dark:text-zinc-100">
                <%= used.name %>
              </h3>
              <p class="relative z-10 mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                <%= used.description %>
              </p>
            </li>
          </ul>
        </div>
      </div>
    </section>
    """
  end
end
