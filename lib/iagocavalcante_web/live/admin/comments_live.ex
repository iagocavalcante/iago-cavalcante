defmodule IagocavalcanteWeb.Admin.CommentsLive do
  use IagocavalcanteWeb, :live_view
  alias Iagocavalcante.Blog

  def mount(_params, _session, socket) do
    if connected?(socket), do: refresh_comments()
    
    pending_comments = Blog.list_pending_comments()

    {:ok,
     socket
     |> assign(:pending_comments, pending_comments)
     |> assign(:loading, false)
     |> assign(:current_page, :comments)
     |> assign(:pending_comments_count, length(pending_comments))}
  end

  def render(assigns) do
    ~H"""
    <IagocavalcanteWeb.Components.AdminNav.admin_navigation 
      current_page={@current_page}
      pending_comments_count={@pending_comments_count}
    />
    
    <div class="sm:px-8 mt-8 lg:mt-16">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-5xl">
            <div class="flex items-center justify-between mb-8">
              <h1 class="text-3xl font-bold text-zinc-900 dark:text-zinc-100">
                Comment Moderation
              </h1>
              <div class="text-sm text-zinc-500 dark:text-zinc-400">
                <%= length(@pending_comments) %> pending comments
              </div>
            </div>

            <%= if Enum.empty?(@pending_comments) do %>
              <div class="text-center py-12">
                <svg class="mx-auto h-12 w-12 text-zinc-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <h3 class="mt-2 text-lg font-medium text-zinc-900 dark:text-zinc-100">No pending comments</h3>
                <p class="mt-1 text-zinc-500 dark:text-zinc-400">All comments have been reviewed!</p>
              </div>
            <% else %>
              <div class="space-y-6">
                <%= for comment <- @pending_comments do %>
                  <div class="bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-lg p-6 shadow-sm">
                    <div class="flex items-start justify-between">
                      <div class="flex-1">
                        <div class="flex items-center space-x-2">
                          <h3 class="text-lg font-medium text-zinc-900 dark:text-zinc-100">
                            <%= comment.author_name %>
                          </h3>
                          <span class="text-zinc-400">•</span>
                          <p class="text-sm text-zinc-500 dark:text-zinc-400">
                            <%= comment.author_email %>
                          </p>
                          <span class="text-zinc-400">•</span>
                          <time class="text-sm text-zinc-500 dark:text-zinc-400">
                            <%= format_datetime(comment.inserted_at) %>
                          </time>
                        </div>

                        <div class="mt-2">
                          <p class="text-sm text-zinc-600 dark:text-zinc-400">
                            Post: <span class="font-medium"><%= comment.post_id %></span>
                          </p>
                        </div>

                        <div class="mt-4 prose prose-sm dark:prose-invert">
                          <%= format_content(comment.content) %>
                        </div>

                        <div class="mt-4 flex items-center space-x-4 text-xs text-zinc-500 dark:text-zinc-400">
                          <span>IP: <%= comment.ip_address %></span>
                          <span>Spam Score: 
                            <span class={[
                              "font-medium",
                              spam_score_color(comment.spam_score)
                            ]}>
                              <%= Float.round(comment.spam_score * 100, 1) %>%
                            </span>
                          </span>
                        </div>
                      </div>

                      <div class="ml-4 flex-shrink-0 flex flex-col space-y-2">
                        <button
                          phx-click="approve_comment"
                          phx-value-comment-id={comment.id}
                          disabled={@loading}
                          class="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50"
                        >
                          <svg class="mr-1 h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                          </svg>
                          Approve
                        </button>

                        <button
                          phx-click="reject_comment"
                          phx-value-comment-id={comment.id}
                          disabled={@loading}
                          class="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50"
                        >
                          <svg class="mr-1 h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                          </svg>
                          Reject
                        </button>

                        <button
                          phx-click="mark_spam"
                          phx-value-comment-id={comment.id}
                          disabled={@loading}
                          class="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded-md text-white bg-orange-600 hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 disabled:opacity-50"
                        >
                          <svg class="mr-1 h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
                          </svg>
                          Spam
                        </button>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("approve_comment", %{"comment-id" => comment_id}, socket) do
    socket = assign(socket, :loading, true)

    case Blog.approve_comment(comment_id) do
      {:ok, _comment} ->
        pending_comments = Blog.list_pending_comments()
        
        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:pending_comments, pending_comments)
         |> assign(:pending_comments_count, length(pending_comments))
         |> put_flash(:info, "Comment approved successfully!")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> put_flash(:error, "Error approving comment")}
    end
  end

  def handle_event("reject_comment", %{"comment-id" => comment_id}, socket) do
    socket = assign(socket, :loading, true)

    case Blog.reject_comment(comment_id) do
      {:ok, _comment} ->
        pending_comments = Blog.list_pending_comments()
        
        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:pending_comments, pending_comments)
         |> assign(:pending_comments_count, length(pending_comments))
         |> put_flash(:info, "Comment rejected")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> put_flash(:error, "Error rejecting comment")}
    end
  end

  def handle_event("mark_spam", %{"comment-id" => comment_id}, socket) do
    socket = assign(socket, :loading, true)

    case Blog.mark_as_spam(comment_id) do
      {:ok, _comment} ->
        pending_comments = Blog.list_pending_comments()
        
        {:noreply,
         socket
         |> assign(:loading, false)
         |> assign(:pending_comments, pending_comments)
         |> assign(:pending_comments_count, length(pending_comments))
         |> put_flash(:info, "Comment marked as spam")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> put_flash(:error, "Error marking comment as spam")}
    end
  end

  defp refresh_comments do
    Process.send_after(self(), :refresh_comments, 30_000)  # Refresh every 30 seconds
  end

  def handle_info(:refresh_comments, socket) do
    refresh_comments()
    pending_comments = Blog.list_pending_comments()
    
    {:noreply, 
     socket
     |> assign(:pending_comments, pending_comments)
     |> assign(:pending_comments_count, length(pending_comments))}
  end

  defp format_datetime(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_naive()
    |> NaiveDateTime.to_string()
    |> String.replace("T", " ")
    |> String.slice(0, 16)
  end

  defp format_datetime(%NaiveDateTime{} = naive_datetime) do
    naive_datetime
    |> NaiveDateTime.to_string()
    |> String.replace("T", " ")
    |> String.slice(0, 16)
  end

  defp format_content(content) do
    content
    |> String.replace(~r/\r\n|\r|\n/, "<br>")
    |> Phoenix.HTML.raw()
  end

  defp spam_score_color(score) do
    cond do
      score >= 0.7 -> "text-red-600"
      score >= 0.4 -> "text-orange-600"
      true -> "text-green-600"
    end
  end
end