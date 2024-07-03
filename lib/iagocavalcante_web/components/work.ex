defmodule IagocavalcanteWeb.Work do
  use Phoenix.Component
  import IagocavalcanteWeb.Gettext

  attr :works, :list,
    default: [
      %{
        company: "Terras Apps Solutions",
        role: "Software Engineer Consultant",
        date_start: "2024.1",
        date_end: "Present",
        image: "/images/work/terras.svg",
        image_alt: "Terras Logo",
        url: "https://terras.agr.br/"
      },
      %{
        company: "Zarv Inc.",
        role: "Software Engineer",
        date_start: "2023.1",
        date_end: "2024.1",
        image: "/images/work/zarv.svg",
        image_alt: "Zarv Inc Logo",
        url: "https://zarv.com"
      },
      %{
        company: "Truelogic",
        role: "Software Engineer",
        date_start: "2022",
        date_end: "2023.2",
        image: "/images/work/truelogic.jpg",
        image_alt: "Truelogic Logo",
        url: "https://truelogic.io"
      },
      %{
        company: "IdopterLabs",
        role: "Software Engineer",
        date_start: "2019",
        date_end: "2022",
        image: "/images/work/idopterlabs.svg",
        image_alt: "Idopterlabs Logo",
        url: "https://en.idopterlabs.com.br"
      },
      %{
        company: "Abacomm",
        role: "Software Engineer",
        date_start: "2018",
        date_end: "2019",
        image: "/images/work/abacomm.jpg",
        image_alt: "Abacomm Logo",
        url: "https://abacomm.com.br"
      }
    ]

  def work(assigns) do
    ~H"""
    <li :for={work <- @works} class="flex gap-4">
      <div class="relative mt-1 flex h-10 w-10 flex-none items-center justify-center rounded-full shadow-md shadow-zinc-800/5 ring-1 ring-zinc-900/5 dark:border dark:border-zinc-700/50 dark:bg-zinc-800 dark:ring-0">
        <img
          alt={work.image_alt}
          src={work.image}
          decoding="async"
          data-nimg="1"
          class="h-7 w-7"
          loading="lazy"
          style="color: transparent;"
          width="32"
          height="32"
        />
      </div>
      <dl class="flex flex-auto flex-wrap gap-x-2">
        <dt class="sr-only"><%= gettext("Company") %></dt>
        <dd class="w-full flex-none text-sm font-medium text-zinc-900 dark:text-zinc-100">
          <%= work.company %>
        </dd>
        <dt class="sr-only"><%= gettext("Role") %></dt>
        <dd class="text-xs text-zinc-500 dark:text-zinc-400"><%= work.role %></dd>
        <dt class="sr-only"><%= gettext("Date") %></dt>
        <dd
          class="ml-auto text-xs text-zinc-400 dark:text-zinc-500"
          aria-label={
            gettext("%{date_start} until %{date_end}",
              date_start: work.date_start,
              date_end: work.date_end
            )
          }
        >
          <time datetime="2019"><%= work.date_start %></time> <span aria-hidden="true">—</span>
          <time datetime="2023"><%= work.date_end %></time>
        </dd>
      </dl>
    </li>
    """
  end
end
