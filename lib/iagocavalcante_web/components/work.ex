defmodule IagocavalcanteWeb.Work do
  use Phoenix.Component
  use Gettext, backend: IagocavalcanteWeb.Gettext

  attr :works, :list,
    default: [
      %{
        company: "EasyMate AI",
        role: "Software Engineer",
        date_start: "2025.2",
        date_end: "Present",
        image: "/images/work/easymate.png",
        image_alt: "EasyMate AI Logo",
        url: "https://easymate.ai",
        is_avatar: false
      },
      %{
        company: "Iago Cavalcante Consultoria",
        role: "Software Engineer",
        date_start: "2024",
        date_end: "Present",
        image: "/images/myself-1.png",
        image_alt: "Iago Cavalcante",
        url: "https://iagocavalcante.com",
        is_avatar: true
      },
      %{
        company: "Zarv Inc.",
        role: "Software Engineer",
        date_start: "2023",
        date_end: "2024",
        image: "/images/work/zarv.svg",
        image_alt: "Zarv Inc Logo",
        url: "https://zarv.com",
        is_avatar: false
      },
      %{
        company: "Truelogic",
        role: "Software Engineer",
        date_start: "2022",
        date_end: "2023",
        image: "/images/work/truelogic.jpg",
        image_alt: "Truelogic Logo",
        url: "https://truelogic.io",
        is_avatar: false
      },
      %{
        company: "IdopterLabs",
        role: "Software Engineer",
        date_start: "2019",
        date_end: "2022",
        image: "/images/work/idopterlabs.svg",
        image_alt: "Idopterlabs Logo",
        url: "https://en.idopterlabs.com.br",
        is_avatar: false
      }
    ]

  def work(assigns) do
    ~H"""
    <li
      :for={work <- @works}
      class="group flex gap-4 py-3 border-b border-stone-200 dark:border-stone-800 last:border-0 transition-all duration-200 hover:pl-2"
    >
      <div class={[
        "relative mt-1 flex flex-none items-center justify-center overflow-hidden",
        if(Map.get(work, :is_avatar, false),
          do: "h-10 w-10 rounded-full",
          else: "h-10 w-10 rounded-lg p-1.5"
        ),
        "bg-stone-100 dark:bg-stone-800"
      ]}>
        <img
          alt={work.image_alt}
          src={work.image}
          decoding="async"
          data-nimg="1"
          class={
            if Map.get(work, :is_avatar, false),
              do: "h-full w-full object-cover",
              else: "h-full w-full object-contain"
          }
          loading="lazy"
          style="color: transparent;"
        />
      </div>
      <dl class="flex flex-auto flex-wrap gap-x-2">
        <dt class="sr-only">{gettext("Company")}</dt>
        <dd class="w-full flex-none text-sm font-semibold text-stone-900 dark:text-stone-100 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
          {work.company}
        </dd>
        <dt class="sr-only">{gettext("Role")}</dt>
        <dd class="text-xs text-stone-500 dark:text-stone-500 font-mono uppercase tracking-wider">
          {work.role}
        </dd>
        <dt class="sr-only">{gettext("Date")}</dt>
        <dd
          class="ml-auto text-xs text-stone-400 dark:text-stone-600 font-mono"
          aria-label={
            gettext("%{date_start} until %{date_end}",
              date_start: work.date_start,
              date_end: work.date_end
            )
          }
        >
          <time datetime={work.date_start}>{work.date_start}</time>
          <span aria-hidden="true" class="mx-1">→</span>
          <time datetime={work.date_end}>{work.date_end}</time>
        </dd>
      </dl>
    </li>
    """
  end
end
