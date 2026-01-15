defmodule IagocavalcanteWeb.Components.Comments do
  use IagocavalcanteWeb, :live_component
  alias Iagocavalcante.Blog
  alias Iagocavalcante.Blog.Comment

  def render(assigns) do
    ~H"""
    <div class="mt-16 border-t border-zinc-200 dark:border-zinc-700 pt-8">
      <div class="flex items-center justify-between mb-8">
        <h2 class="text-2xl font-bold text-zinc-900 dark:text-zinc-100">
          Comments ({@comment_count})
        </h2>
      </div>
      
    <!-- Comment Form -->
      <.simple_form :let={f} for={@form} phx-submit="submit_comment" phx-target={@myself} class="mb-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input
            field={{f, :author_name}}
            type="text"
            label="Name *"
            placeholder="Your name"
            required
          />
          <.input
            field={{f, :author_email}}
            type="email"
            label="Email *"
            placeholder="your@email.com"
            required
          />
        </div>

        <.input
          field={{f, :content}}
          type="textarea"
          label="Comment *"
          placeholder="Share your thoughts..."
          rows="4"
          required
        />
        
    <!-- Honeypot field (hidden) -->
        <div style="display: none;">
          <.input field={{f, :website}} type="text" />
        </div>

        <div class="flex items-start space-x-3">
          <input
            type="checkbox"
            id="comment-terms"
            required
            class="mt-1 h-4 w-4 text-blue-600 focus:ring-blue-500 border-zinc-300 dark:border-zinc-600 dark:bg-zinc-800 rounded"
          />
          <label for="comment-terms" class="text-sm text-zinc-600 dark:text-zinc-400">
            I agree that my comment will be moderated before publication and I understand the <a
              href="/privacy"
              class="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
            >privacy policy</a>.
          </label>
        </div>

        <:actions>
          <button
            type="submit"
            disabled={@loading}
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <%= if @loading do %>
              <svg
                class="animate-spin -ml-1 mr-3 h-4 w-4 text-white"
                xmlns="http://www.w3.org/2000/svg"
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
              Submitting...
            <% else %>
              Post Comment
            <% end %>
          </button>
        </:actions>
      </.simple_form>
      
    <!-- Success/Error Messages -->
      <%= if @message do %>
        <div class={[
          "mb-6 p-4 rounded-md",
          if(@message_type == :success,
            do:
              "bg-green-50 dark:bg-green-900/20 text-green-700 dark:text-green-300 border border-green-200 dark:border-green-800",
            else:
              "bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-300 border border-red-200 dark:border-red-800"
          )
        ]}>
          <div class="flex">
            <div class="flex-shrink-0">
              <%= if @message_type == :success do %>
                <svg
                  class="h-5 w-5 text-green-400 dark:text-green-300"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fill-rule="evenodd"
                    d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                    clip-rule="evenodd"
                  />
                </svg>
              <% else %>
                <svg
                  class="h-5 w-5 text-red-400 dark:text-red-300"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fill-rule="evenodd"
                    d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                    clip-rule="evenodd"
                  />
                </svg>
              <% end %>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium">
                {@message}
              </p>
            </div>
          </div>
        </div>
      <% end %>
      
    <!-- Comments List -->
      <div class="space-y-6">
        <%= for comment <- @comments do %>
          <.comment_item comment={comment} post_id={@post_id} myself={@myself} />
        <% end %>

        <%= if Enum.empty?(@comments) do %>
          <div class="text-center py-8 text-zinc-500 dark:text-zinc-400">
            <svg class="mx-auto h-12 w-12 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
              />
            </svg>
            <p class="text-lg font-medium">No comments yet</p>
            <p class="mt-2">Be the first to share your thoughts!</p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def comment_item(assigns) do
    ~H"""
    <div class="border-l-2 border-zinc-200 dark:border-zinc-700 pl-4">
      <div class="flex items-start space-x-3">
        <div class="flex-shrink-0">
          <div class="h-8 w-8 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white text-sm font-medium">
            {String.first(@comment.author_name) |> String.upcase()}
          </div>
        </div>

        <div class="flex-1 min-w-0">
          <div class="flex items-center space-x-2">
            <p class="text-sm font-medium text-zinc-900 dark:text-zinc-100">
              {@comment.author_name}
            </p>
            <span class="text-zinc-500 dark:text-zinc-400">•</span>
            <time class="text-sm text-zinc-500 dark:text-zinc-400">
              {format_date(@comment.inserted_at)}
            </time>
          </div>

          <div class="mt-2 prose prose-sm dark:prose-invert text-zinc-700 dark:text-zinc-300">
            {format_comment_content(@comment.content)}
          </div>

          <div class="mt-3 flex items-center space-x-4">
            <button
              phx-click="reply_to_comment"
              phx-target={@myself}
              phx-value-comment-id={@comment.id}
              class="text-sm text-blue-600 hover:text-blue-800 font-medium"
            >
              Reply
            </button>
          </div>
        </div>
      </div>
      
    <!-- Nested Replies -->
      <%= if length(@comment.replies) > 0 do %>
        <div class="ml-11 mt-4 space-y-4">
          <%= for reply <- @comment.replies do %>
            <.comment_item comment={reply} post_id={@post_id} myself={@myself} />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(:loading, false)
     |> assign(:message, nil)
     |> assign(:message_type, nil)
     |> assign(:reply_to, nil)}
  end

  def update(%{post_id: post_id} = assigns, socket) do
    comments = Blog.list_comments_for_post(post_id)
    comment_count = Blog.comment_count_for_post(post_id)
    changeset = Comment.changeset(%Comment{}, %{})
    form = to_form(changeset, as: :comment)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:comments, comments)
     |> assign(:comment_count, comment_count)
     |> assign(:form, form)}
  end

  def handle_event("submit_comment", %{"website" => website} = _params, socket)
      when website != "" do
    # Honeypot field filled - likely spam
    {:noreply,
     socket
     |> assign(:message, "There was an error submitting your comment. Please try again.")
     |> assign(:message_type, :error)
     |> assign(:loading, false)}
  end

  def handle_event("submit_comment", comment_params, socket) do
    comment_attrs = %{
      "post_id" => socket.assigns.post_id,
      "author_name" => comment_params["author_name"],
      "author_email" => comment_params["author_email"],
      "content" => comment_params["content"],
      "ip_address" => get_client_ip(socket),
      "user_agent" => get_user_agent(socket),
      "parent_id" => socket.assigns.reply_to
    }

    socket = assign(socket, :loading, true)

    case Blog.create_comment(comment_attrs) do
      {:ok, comment} ->
        message =
          case comment.status do
            :approved ->
              "Your comment has been posted successfully!"

            :pending ->
              "Thank you for your comment! It will be reviewed and published soon."

            :spam ->
              "Your comment couldn't be posted. Please contact us if you believe this is an error."
          end

        message_type = if comment.status == :approved, do: :success, else: :success

        # Refresh comments list
        comments = Blog.list_comments_for_post(socket.assigns.post_id)
        comment_count = Blog.comment_count_for_post(socket.assigns.post_id)

        {:noreply,
         socket
         |> assign(:comments, comments)
         |> assign(:comment_count, comment_count)
         |> assign(:form, to_form(Comment.changeset(%Comment{}, %{}), as: :comment))
         |> assign(:message, message)
         |> assign(:message_type, message_type)
         |> assign(:loading, false)
         |> assign(:reply_to, nil)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> assign(:message, "Please check the errors below and try again.")
         |> assign(:message_type, :error)
         |> assign(:loading, false)}
    end
  end

  def handle_event("reply_to_comment", %{"comment-id" => comment_id}, socket) do
    {:noreply, assign(socket, :reply_to, String.to_integer(comment_id))}
  end

  defp get_client_ip(socket) do
    try do
      case Phoenix.LiveView.get_connect_info(socket, :peer_data) do
        %{address: address} -> :inet.ntoa(address) |> to_string()
        _ -> "unknown"
      end
    rescue
      # Default for tests
      RuntimeError -> "127.0.0.1"
    end
  end

  defp get_user_agent(socket) do
    try do
      case Phoenix.LiveView.get_connect_info(socket, :user_agent) do
        user_agent when is_binary(user_agent) -> user_agent
        _ -> "unknown"
      end
    rescue
      # Default for tests
      RuntimeError -> "test-agent"
    end
  end

  defp format_date(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_date()
    |> Date.to_string()
  end

  defp format_date(%NaiveDateTime{} = naive_datetime) do
    naive_datetime
    |> NaiveDateTime.to_date()
    |> Date.to_string()
  end

  defp format_comment_content(content) do
    content
    |> String.replace(~r/\r\n|\r|\n/, "<br>")
    |> Phoenix.HTML.raw()
  end
end
