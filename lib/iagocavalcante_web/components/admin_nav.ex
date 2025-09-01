defmodule IagocavalcanteWeb.Components.AdminNav do
  use Phoenix.Component

  def admin_navigation(assigns) do
    ~H"""
    <nav class="bg-white dark:bg-zinc-800 shadow-sm border-b border-zinc-200 dark:border-zinc-700 mb-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <div class="flex-shrink-0 flex items-center">
              <h2 class="text-lg font-semibold text-zinc-900 dark:text-zinc-100">
                Admin Panel
              </h2>
            </div>
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <.admin_nav_link 
                href="/admin/posts" 
                active={@current_page == :posts}
                badge_count={nil}
              >
                Posts
              </.admin_nav_link>
              
              <.admin_nav_link 
                href="/admin/comments" 
                active={@current_page == :comments}
                badge_count={@pending_comments_count}
              >
                Comments
              </.admin_nav_link>
              
              <.admin_nav_link 
                href="/admin/videos" 
                active={@current_page == :videos}
                badge_count={nil}
              >
                Videos
              </.admin_nav_link>
            </div>
          </div>
          
          <div class="flex items-center space-x-4">
            <a
              href="/"
              class="text-zinc-500 dark:text-zinc-400 hover:text-zinc-700 dark:hover:text-zinc-300 px-3 py-2 rounded-md text-sm font-medium"
            >
              ← Back to Site
            </a>
            
            <.link
              href="/users/log_out"
              method="delete"
              class="bg-red-600 hover:bg-red-700 text-white px-3 py-2 rounded-md text-sm font-medium"
            >
              Sign out
            </.link>
          </div>
        </div>
      </div>
    </nav>
    """
  end

  defp admin_nav_link(assigns) do
    ~H"""
    <a
      href={@href}
      class={[
        "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium",
        if(@active,
          do: "border-blue-500 text-zinc-900 dark:text-zinc-100",
          else: "border-transparent text-zinc-500 dark:text-zinc-400 hover:text-zinc-700 dark:hover:text-zinc-300 hover:border-zinc-300 dark:hover:border-zinc-600"
        )
      ]}
    >
      <%= render_slot(@inner_block) %>
      <%= if @badge_count && @badge_count > 0 do %>
        <span class="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200">
          <%= @badge_count %>
        </span>
      <% end %>
    </a>
    """
  end
end