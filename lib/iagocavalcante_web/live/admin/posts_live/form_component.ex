defmodule IagocavalcanteWeb.Admin.PostsLive.FormComponent do
  use IagocavalcanteWeb, :live_component

  alias Iagocavalcante.Blog
  alias Iagocavalcante.Subscribers
  alias IagocavalcanteWeb.Admin.Components.WysiwygEditor

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-gray-900">
      <div class="max-w-4xl mx-auto">
        <!-- Header Section -->
        <div class="pt-12 pb-8 px-6">
          <div class="text-center">
            <h1 class="text-4xl font-bold text-gray-900 dark:text-white mb-4">
              {if @action == :edit, do: "Edit Story", else: "Write a new story"}
            </h1>
            <p class="text-xl text-gray-600 dark:text-gray-400">
              {if @action == :edit, do: "Update your story", else: "Share your ideas with the world"}
            </p>
          </div>
        </div>

        <form
          id="posts-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="show_publish_modal"
          class="px-6"
        >
          <!-- Story Metadata -->
          <div class="mb-12 space-y-8">
            <!-- Title Input - Medium Style -->
            <div class="space-y-2">
              <input
                type="text"
                id={@form[:title].id}
                name={@form[:title].name}
                value={Phoenix.HTML.Form.normalize_value("text", @form[:title].value)}
                placeholder="Title"
                required
                class="w-full text-5xl font-bold border-none outline-none bg-transparent placeholder-gray-400 dark:placeholder-gray-500 text-gray-900 dark:text-white resize-none"
                style="line-height: 1.2;"
              />
            </div>
            
    <!-- Subtitle/Description - Medium Style -->
            <div class="space-y-2">
              <textarea
                id={@form[:description].id}
                name={@form[:description].name}
                placeholder="Tell readers what this story is about..."
                rows="2"
                required
                class="w-full text-2xl font-light border-none outline-none bg-transparent placeholder-gray-400 dark:placeholder-gray-500 text-gray-600 dark:text-gray-300 resize-none"
                style="line-height: 1.4;"
              ><%= Phoenix.HTML.Form.normalize_value("textarea", @form[:description].value) %></textarea>
            </div>
            
    <!-- Metadata Row -->
            <div class="flex flex-wrap items-center gap-6 pt-4 border-t border-gray-200 dark:border-gray-700">
              <div class="flex items-center space-x-2">
                <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Language:</label>
                <select
                  id={@form[:locale].id}
                  name={@form[:locale].name}
                  required
                  class="text-sm border-none bg-transparent text-gray-600 dark:text-gray-400 focus:outline-none"
                >
                  <option value="en" selected={@form[:locale].value == "en"}>English</option>
                  <option value="pt_BR" selected={@form[:locale].value == "pt_BR"}>Portuguese</option>
                </select>
              </div>

              <div class="flex items-center space-x-2 flex-1">
                <label class="text-sm font-medium text-gray-700 dark:text-gray-300">Tags:</label>
                <input
                  type="text"
                  id={@form[:tags].id}
                  name={@form[:tags].name}
                  value={Phoenix.HTML.Form.normalize_value("text", @form[:tags].value)}
                  placeholder="Add tags (comma separated)"
                  required
                  class="flex-1 text-sm border-none bg-transparent text-gray-600 dark:text-gray-400 placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none"
                />
              </div>

              <div class="text-sm text-gray-500 dark:text-gray-400">
                <span id="slug-preview-url">
                  /blog/<span class="font-mono"><%= if @form[:title].value, do: slug_from_title(@form[:title].value), else: "your-post-title" %></span>
                </span>
              </div>
            </div>
          </div>
          
    <!-- Medium-Style WYSIWYG Editor -->
          <div class="mb-6">
            <.live_component
              module={WysiwygEditor}
              id="wysiwyg-editor"
              content={@editor_content}
              name={@form[:body].name}
              parent_id={@id}
            />
          </div>
          
    <!-- Content Spacing for Fixed Bottom Bar -->
          <div class="h-20"></div>
        </form>
        
    <!-- Medium-Style Action Bar -->
        <div class="fixed bottom-0 left-0 right-0 bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 px-6 py-4 z-10">
          <div class="max-w-4xl mx-auto flex items-center justify-between">
            <div class="flex items-center space-x-4">
              <button
                type="button"
                phx-click="save_draft"
                phx-target={@myself}
                class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                Save Draft
              </button>
            </div>

            <div class="flex items-center space-x-4">
              <span class="text-sm text-gray-500 dark:text-gray-400">
                Auto-saved
              </span>
              <button
                type="submit"
                form="posts-form"
                phx-disable-with="Publishing..."
                class="px-6 py-2 bg-green-600 hover:bg-green-700 text-white font-medium rounded-full transition-colors"
              >
                {if @action == :edit, do: "Update", else: "Publish"}
              </button>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Publish Confirmation Modal -->
      <%= if @show_publish_modal do %>
        <div
          class="fixed inset-0 z-50 overflow-y-auto"
          aria-labelledby="modal-title"
          role="dialog"
          aria-modal="true"
        >
          <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <!-- Background overlay -->
            <div
              class="fixed inset-0 bg-gray-500 dark:bg-gray-900 bg-opacity-75 dark:bg-opacity-75 transition-opacity"
              aria-hidden="true"
              phx-click="close_publish_modal"
              phx-target={@myself}
            >
            </div>
            
    <!-- Modal panel -->
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">
              &#8203;
            </span>

            <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
              <div class="bg-white dark:bg-gray-800 px-6 pt-6 pb-4">
                <div class="sm:flex sm:items-start">
                  <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-green-100 dark:bg-green-900 sm:mx-0 sm:h-10 sm:w-10">
                    <svg
                      class="h-6 w-6 text-green-600 dark:text-green-400"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M12 7.5h1.5m-1.5 3h1.5m-7.5 3h7.5m-7.5 3h7.5m3-9h3.375c.621 0 1.125.504 1.125 1.125V18a2.25 2.25 0 01-2.25 2.25M16.5 7.5V18a2.25 2.25 0 002.25 2.25M16.5 7.5V4.875c0-.621-.504-1.125-1.125-1.125H4.125C3.504 3.75 3 4.254 3 4.875V18a2.25 2.25 0 002.25 2.25h13.5M6 7.5h3v3H6v-3z"
                      />
                    </svg>
                  </div>
                  <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left flex-1">
                    <h3
                      class="text-lg leading-6 font-semibold text-gray-900 dark:text-white"
                      id="modal-title"
                    >
                      {if @action == :edit, do: "Update Story", else: "Ready to publish?"}
                    </h3>
                    <div class="mt-2">
                      <p class="text-sm text-gray-500 dark:text-gray-400">
                        {if @action == :edit,
                          do: "Your story will be updated and available to readers.",
                          else: "Your story will be published and visible to everyone."}
                      </p>
                    </div>
                  </div>
                </div>
                
    <!-- Post Preview -->
                <div class="mt-4 p-4 bg-gray-50 dark:bg-gray-700 rounded-xl">
                  <h4 class="font-semibold text-gray-900 dark:text-white text-lg">
                    {@pending_post_params["title"]}
                  </h4>
                  <p class="text-gray-600 dark:text-gray-300 text-sm mt-1 line-clamp-2">
                    {@pending_post_params["description"]}
                  </p>
                  <div class="flex items-center gap-2 mt-3">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200">
                      {@pending_post_params["locale"]}
                    </span>
                    <%= for tag <- String.split(@pending_post_params["tags"] || "", ",") do %>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 dark:bg-gray-600 text-gray-800 dark:text-gray-200">
                        {String.trim(tag)}
                      </span>
                    <% end %>
                  </div>
                </div>
                
    <!-- Newsletter Notification Option -->
                <%= if @action == :new do %>
                  <div class="mt-4 p-4 border border-gray-200 dark:border-gray-600 rounded-xl">
                    <label class="flex items-start cursor-pointer">
                      <div class="flex items-center h-5">
                        <input
                          type="checkbox"
                          checked={@notify_subscribers}
                          phx-click="toggle_notify_subscribers"
                          phx-target={@myself}
                          class="h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300 dark:border-gray-600 rounded cursor-pointer"
                        />
                      </div>
                      <div class="ml-3">
                        <span class="text-sm font-medium text-gray-900 dark:text-white">
                          Notify newsletter subscribers
                        </span>
                        <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
                          Send an email notification to {@subscriber_count} verified subscriber(s)
                        </p>
                      </div>
                    </label>
                  </div>
                <% end %>
                
    <!-- Notification Progress -->
                <%= if @notification_status do %>
                  <div class="mt-4 p-4 bg-blue-50 dark:bg-blue-900/30 rounded-xl">
                    <div class="flex items-center">
                      <%= case @notification_status do %>
                        <% :sending -> %>
                          <svg
                            class="animate-spin h-5 w-5 text-blue-600 dark:text-blue-400 mr-3"
                            fill="none"
                            viewBox="0 0 24 24"
                          >
                            <circle
                              class="opacity-25"
                              cx="12"
                              cy="12"
                              r="10"
                              stroke="currentColor"
                              stroke-width="4"
                            >
                            </circle>
                            <path
                              class="opacity-75"
                              fill="currentColor"
                              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                            >
                            </path>
                          </svg>
                          <span class="text-sm text-blue-700 dark:text-blue-300">
                            Sending notifications... ({@notifications_sent}/{@notifications_total})
                          </span>
                        <% :completed -> %>
                          <svg
                            class="h-5 w-5 text-green-600 dark:text-green-400 mr-3"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke-width="1.5"
                            stroke="currentColor"
                          >
                            <path
                              stroke-linecap="round"
                              stroke-linejoin="round"
                              d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                            />
                          </svg>
                          <span class="text-sm text-green-700 dark:text-green-300">
                            All {@notifications_sent} notifications sent successfully!
                          </span>
                        <% :error -> %>
                          <svg
                            class="h-5 w-5 text-red-600 dark:text-red-400 mr-3"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke-width="1.5"
                            stroke="currentColor"
                          >
                            <path
                              stroke-linecap="round"
                              stroke-linejoin="round"
                              d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z"
                            />
                          </svg>
                          <span class="text-sm text-red-700 dark:text-red-300">
                            Sent {@notifications_sent}/{@notifications_total} notifications
                            ({@notifications_failed} failed)
                          </span>
                        <% _ -> %>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>

              <div class="bg-gray-50 dark:bg-gray-700 px-6 py-4 sm:flex sm:flex-row-reverse gap-3">
                <button
                  type="button"
                  phx-click="confirm_publish"
                  phx-target={@myself}
                  disabled={@notification_status == :sending}
                  class="w-full inline-flex justify-center rounded-full border border-transparent shadow-sm px-6 py-2 bg-green-600 text-base font-medium text-white hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 sm:w-auto sm:text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {if @action == :edit, do: "Update Story", else: "Publish Now"}
                </button>
                <button
                  type="button"
                  phx-click="close_publish_modal"
                  phx-target={@myself}
                  disabled={@notification_status == :sending}
                  class="mt-3 w-full inline-flex justify-center rounded-full border border-gray-300 dark:border-gray-600 shadow-sm px-6 py-2 bg-white dark:bg-gray-800 text-base font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 sm:mt-0 sm:w-auto sm:text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(%{editor_content: content}, socket) do
    # Handle editor content updates from WysiwygEditor
    {:ok, assign(socket, :editor_content, content)}
  end

  @impl true
  def update(%{notification_progress: progress}, socket) do
    # Handle async notification progress updates
    {:ok,
     socket
     |> assign(:notifications_sent, progress.sent)
     |> assign(:notifications_failed, progress.failed)
     |> assign(:notification_status, progress.status)}
  end

  @impl true
  def update(%{posts: post} = assigns, socket) do
    # Convert Post struct to map for form handling
    post_data =
      case post do
        %Iagocavalcante.Post{} = p ->
          %{
            "title" => p.title,
            "description" => p.description,
            "body" => p.body,
            "tags" => Enum.join(p.tags, ", "),
            "locale" => p.locale,
            "published" => p.published
          }

        %{} = p ->
          p

        _ ->
          %{}
      end

    subscriber_count = Subscribers.count_verified_subscribers()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(post_data))
     |> assign(:editor_content, post_data["body"] || "")
     |> assign(:show_publish_modal, false)
     |> assign(:notify_subscribers, true)
     |> assign(:subscriber_count, subscriber_count)
     |> assign(:pending_post_params, %{})
     |> assign(:notification_status, nil)
     |> assign(:notifications_sent, 0)
     |> assign(:notifications_total, 0)
     |> assign(:notifications_failed, 0)}
  end

  @impl true
  def handle_event("validate", posts_params, socket) do
    {:noreply, assign(socket, :form, to_form(posts_params))}
  end

  @impl true
  def handle_event("show_publish_modal", posts_params, socket) do
    # Include editor content in the form params and show confirmation modal
    posts_params = Map.put(posts_params, "body", socket.assigns.editor_content)

    {:noreply,
     socket
     |> assign(:show_publish_modal, true)
     |> assign(:pending_post_params, posts_params)
     |> assign(:notification_status, nil)}
  end

  @impl true
  def handle_event("close_publish_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_publish_modal, false)
     |> assign(:notification_status, nil)}
  end

  @impl true
  def handle_event("toggle_notify_subscribers", _params, socket) do
    {:noreply, assign(socket, :notify_subscribers, !socket.assigns.notify_subscribers)}
  end

  @impl true
  def handle_event("confirm_publish", _params, socket) do
    save_posts(socket, socket.assigns.action, socket.assigns.pending_post_params)
  end

  @impl true
  def handle_event("save_draft", _params, socket) do
    # Get form data from assigns since this button is outside the form
    posts_params =
      socket.assigns.form.params
      |> Map.put("published", false)
      |> Map.put("body", socket.assigns.editor_content)

    save_posts(socket, socket.assigns.action, posts_params)
  end

  defp save_posts(socket, :edit, posts_params) do
    case Blog.update_post(socket.assigns.posts.id, posts_params) do
      :ok ->
        {:noreply,
         socket
         |> assign(:show_publish_modal, false)
         |> put_flash(:info, "Post updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:show_publish_modal, false)
         |> put_flash(:error, "Failed to update post: #{inspect(reason)}")
         |> assign(:form, to_form(posts_params))}
    end
  end

  defp save_posts(socket, :new, posts_params) do
    posts_params = Map.put_new(posts_params, "published", true)
    day = String.pad_leading("#{Date.utc_today().day}", 2, "0")
    month = String.pad_leading("#{Date.utc_today().month}", 2, "0")
    year = Date.utc_today().year

    post_params =
      posts_params
      |> Map.put("path", "#{month}-#{day}-#{slug_from_title(posts_params)}.md")
      |> Map.put("slug", slug_from_title(posts_params))
      |> Map.put("year", year)

    case Blog.create_new_post(post_params) do
      :ok ->
        if socket.assigns.notify_subscribers do
          # Start async notification with progress tracking
          component_pid = self()
          subscriber_count = socket.assigns.subscriber_count

          Task.Supervisor.start_child(Iagocavalcante.TaskSupervisor, fn ->
            Subscribers.notify_new_post_async(post_params, component_pid, socket.assigns.id)
          end)

          {:noreply,
           socket
           |> assign(:notification_status, :sending)
           |> assign(:notifications_total, subscriber_count)
           |> assign(:notifications_sent, 0)
           |> put_flash(:info, "Post published! Sending notifications...")}
        else
          {:noreply,
           socket
           |> assign(:show_publish_modal, false)
           |> put_flash(:info, "Post published successfully")
           |> push_patch(to: socket.assigns.patch)}
        end

      _ ->
        {:noreply,
         socket
         |> assign(:show_publish_modal, false)
         |> put_flash(:error, "Error when creating post file")
         |> assign(:form, to_form(posts_params))}
    end
  end

  defp slug_from_title(title) when is_binary(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.replace(~r/^-+|-+$/, "")
  end

  defp slug_from_title(%{"title" => title}) when is_binary(title) do
    slug_from_title(title)
  end

  defp slug_from_title(post) when is_map(post) do
    case post["title"] do
      title when is_binary(title) -> slug_from_title(title)
      _ -> "untitled"
    end
  end

  defp slug_from_title(_), do: "untitled"
end
