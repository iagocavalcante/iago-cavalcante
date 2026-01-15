defmodule IagocavalcanteWeb.NavItem do
  use Phoenix.Component

  attr :link, :string, required: true
  attr :text, :string, required: true
  attr :id, :string, default: nil, doc: "Navigation item ID for active state matching"
  attr :active_item, :atom
  attr :rest, :global, doc: "Any other attributes to be passed to the link"

  def nav_item(assigns) do
    # Use :id if provided, otherwise extract from link path
    nav_id = assigns[:id] || extract_id_from_link(assigns.link)
    assigns = assign(assigns, :is_active, is_active?(nav_id, assigns.active_item))

    ~H"""
    <li class="contents">
      <!-- Desktop Nav Link -->
      <a
        class={[
          "nav-link-desktop hidden md:flex items-center px-4 py-2 rounded-full text-sm font-medium transition-all duration-200",
          if(@is_active, do: "active text-ink", else: "text-ink-light hover:text-ink")
        ]}
        href={@link}
        {@rest}
      >
        {@text}
      </a>
      
    <!-- Mobile Nav Link -->
      <a
        class="md:hidden group flex items-center justify-between py-4 px-2"
        href={@link}
        {@rest}
      >
        <span class={[
          "text-2xl font-display font-semibold transition-all duration-300",
          if(@is_active, do: "text-amber-400", else: "text-stone-100 group-hover:text-amber-400")
        ]}>
          {@text}
        </span>
        <svg
          class={[
            "w-5 h-5 transition-all duration-300 transform group-hover:translate-x-1",
            if(@is_active, do: "text-amber-400", else: "text-stone-500 group-hover:text-amber-400")
          ]}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.5"
            d="M17 8l4 4m0 0l-4 4m4-4H3"
          />
        </svg>
      </a>
    </li>
    """
  end

  # Extract the navigation ID from the link path
  # e.g., "/about" -> "about", "/pt_BR/sobre" -> "sobre" -> maps to "about"
  defp extract_id_from_link(link) do
    link
    |> String.split("/")
    |> List.last()
    |> String.downcase()
    |> normalize_path_to_id()
  end

  # Normalize translated paths to their English ID equivalents
  defp normalize_path_to_id("sobre"), do: "about"
  defp normalize_path_to_id("artigos"), do: "articles"
  defp normalize_path_to_id("projetos"), do: "projects"
  defp normalize_path_to_id("palestras"), do: "speaking"
  defp normalize_path_to_id("videos"), do: "videos"
  defp normalize_path_to_id("usos"), do: "uses"
  defp normalize_path_to_id("favoritos"), do: "bookmarks"
  defp normalize_path_to_id(path), do: path

  defp is_active?(nav_id, active_item) when is_atom(active_item) do
    nav_id == Atom.to_string(active_item)
  end

  defp is_active?(_nav_id, _active_item), do: false
end
