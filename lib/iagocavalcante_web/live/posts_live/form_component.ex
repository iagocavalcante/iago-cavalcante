defmodule IagocavalcanteWeb.PostsLive.FormComponent do
  use IagocavalcanteWeb, :live_component

  alias Iagocavalcante.Blog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= @title %>

      <.simple_form for={@form} id="posts-form" phx-target={@myself} phx-submit="save">
        <.input field={{@form, :title}} type="text" label="Title" required />
        <.input field={{@form, :tags}} type="text" label="Tags (split with comma)" required />
        <.input field={{@form, :locale}} type="text" label="Locale" required />
        <.input field={{@form, :description}} type="textarea" cols="80" label="Description" required />
        <.input
          field={{@form, :body}}
          type="textarea"
          style="font-family: Arial;font-size: 12pt;width:100%;height:100vw"
          cols="80"
          label="Body"
          required
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Posts</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{posts: post} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(post))}
  end

  def handle_event("save", posts_params, socket) do
    save_posts(socket, socket.assigns.action, posts_params)
  end

  defp save_posts(socket, :edit, posts_params) do
    case Blogs.update_posts(socket.assigns.posts, posts_params) do
      {:ok, posts} ->
        notify_parent({:saved, posts})

        {:noreply,
         socket
         |> put_flash(:info, "Posts updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:form, to_form(changeset))}
    end
  end

  defp save_posts(socket, :new, posts_params) do
    locale = posts_params["locale"]
    day = Date.utc_today().day
    month = Date.utc_today().month
    year = Date.utc_today().year

    post_params =
      Map.put(
        posts_params,
        "path",
        "#{month}-#{day}-#{slug_from_title(posts_params)}-#{locale}.md"
      )
      |> Map.put("slug", slug_from_title(posts_params))
      |> Map.put("year", year)

    case Blog.create_new_post(post_params) do
      :ok ->
        IO.inspect("ok")
        notify_parent(:saved)

        {:noreply,
         socket
         |> put_flash(:info, "Posts created successfully")
         |> push_patch(to: Routes.post_path(socket, :index))}

      {:error, :enoent}->
        {:noreply,
         socket
         |> put_flash(:error, "Error when create file to post")
         |> assign(:form, to_form(posts_params))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp slug_from_title(post) do
    post["title"]
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.replace(~r/^-+|-+$/, "")
  end
end
