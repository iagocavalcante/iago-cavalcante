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
              <%= if @action == :edit, do: "Edit Story", else: "Write a new story" %>
            </h1>
            <p class="text-xl text-gray-600 dark:text-gray-400">
              <%= if @action == :edit, do: "Update your story", else: "Share your ideas with the world" %>
            </p>
          </div>
        </div>

        <form id="posts-form" phx-target={@myself} phx-submit="save" class="px-6">
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
                <%= if @action == :edit, do: "Update", else: "Publish" %>
              </button>
            </div>
          </div>
        </div>

        <!-- JavaScript for slug preview -->
        <script>
          document.addEventListener('DOMContentLoaded', function() {
            const titleInput = document.querySelector('input[name="title"]');
            const slugPreview = document.querySelector('#slug-preview-url span.font-mono');
            
            if (titleInput && slugPreview) {
              titleInput.addEventListener('input', function() {
                const slug = this.value
                  .toLowerCase()
                  .replace(/[^a-z0-9]+/g, '-')
                  .replace(/^-+|-+$/g, '');
                slugPreview.textContent = slug || 'your-post-title';
              });
            }
          });
        </script>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{editor_content: content}, socket) do
    # Handle editor content updates from WysiwygEditor
    {:ok, assign(socket, :editor_content, content)}
  end

  @impl true
  def update(%{posts: post} = assigns, socket) do
    # Convert Post struct to map for form handling
    post_data = case post do
      %Iagocavalcante.Post{} = p ->
        %{
          "title" => p.title,
          "description" => p.description,
          "body" => p.body,
          "tags" => Enum.join(p.tags, ", "),
          "locale" => p.locale,
          "published" => p.published
        }
      %{} = p -> p
      _ -> %{}
    end
    
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(post_data))
     |> assign(:editor_content, post_data["body"] || "")}
  end

  @impl true
  def handle_event("save", posts_params, socket) do
    # Include editor content in the form params
    posts_params = Map.put(posts_params, "body", socket.assigns.editor_content)
    save_posts(socket, socket.assigns.action, posts_params)
  end

  @impl true
  def handle_event("save_draft", posts_params, socket) do
    posts_params = 
      posts_params
      |> Map.put("published", false)
      |> Map.put("body", socket.assigns.editor_content)
    save_posts(socket, socket.assigns.action, posts_params)
  end


  defp save_posts(socket, :edit, posts_params) do
    case Blog.update_post(socket.assigns.posts.id, posts_params) do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_patch(to: socket.assigns.patch)}
      
      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to update post: #{inspect(reason)}")
         |> assign(:form, to_form(posts_params))}
    end
  end

  defp save_posts(socket, :new, posts_params) do
    posts_params = Map.put_new(posts_params, "published", true)
    _locale = posts_params["locale"]
    day = if Date.utc_today().day < 10, do: "0#{Date.utc_today().day}", else: Date.utc_today().day

    month =
      if Date.utc_today().month < 10,
        do: "0#{Date.utc_today().month}",
        else: Date.utc_today().month

    year = Date.utc_today().year

    post_params =
      Map.put(
        posts_params,
        "path",
        "#{month}-#{day}-#{slug_from_title(posts_params)}.md"
      )
      |> Map.put("slug", slug_from_title(posts_params))
      |> Map.put("year", year)

    case Blog.create_new_post(post_params) do
      :ok ->
        Subscribers.notify_new_post(post_params)

        {:noreply,
         socket
         |> put_flash(:info, "Posts created successfully")
         |> push_patch(to: socket.assigns.patch)}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Error when create file to post")
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