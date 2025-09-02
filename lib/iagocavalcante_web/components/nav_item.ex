defmodule IagocavalcanteWeb.NavItem do
  use Phoenix.Component

  attr :link, :string, required: true
  attr :text, :string, required: true
  attr :active_item, :atom
  attr :rest, :global, doc: "Any other attributes to be passed to the link"

  def nav_item(assigns) do
    ~H"""
    <li>
      <a class={["relative block transition", desktop_and_mobile_classes(assigns)]} href={@link} @rest>
        <%= @text %>
        <%= if atom_to_string(@active_item) =~ String.downcase(@text) do %>
          <span class="absolute inset-x-1 -bottom-px h-px bg-gradient-to-r from-teal-500/0 via-teal-500/40 to-teal-500/0 dark:from-teal-400/0 dark:via-teal-400/40 dark:to-teal-400/0 hidden md:block">
          </span>
        <% end %>
      </a>
    </li>
    """
  end

  defp desktop_and_mobile_classes(assigns) do
    text_downcase = String.downcase(assigns.text)
    active_item = atom_to_string(assigns.active_item)
    
    base_classes = "px-3 py-2 md:px-3 md:py-2"
    mobile_specific = "md:rounded-none py-3 text-base"
    
    if active_item =~ text_downcase do
      [base_classes, mobile_specific, "text-teal-500 dark:text-teal-400"]
    else
      [base_classes, mobile_specific, "hover:text-teal-500 dark:hover:text-teal-400"]
    end
  end


  defp atom_to_string(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
  end
end
