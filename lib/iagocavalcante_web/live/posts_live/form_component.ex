defmodule IagocavalcanteWeb.PostsLive.FormComponent do
  use IagocavalcanteWeb, :live_component

  alias Iagocavalcante.Blogs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= @title %>

      <.simple_form
        for={@form}
        id="posts-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{@form, :title}} type="text" label="Title" required />
        <.input field={{@form, :description}} type="textarea" cols="80" label="Description" required />
        <.input field={{@form, :body}} type="textarea" cols="80" label="Body" required />
        <.input field={{@form, :user_id}} type="text" label="Author" required />
        <:actions>
          <.button phx-disable-with="Saving...">Save Posts</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{posts: posts} = assigns, socket) do
    changeset = Blogs.change_posts(posts)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"posts" => posts_params}, socket) do
    changeset =
      socket.assigns.posts
      |> Blogs.change_posts(posts_params)
      # |> slug_from_title()
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"posts" => posts_params}, socket) do
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
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_posts(socket, :new, posts_params) do
    post_with_slug = slug_from_title(posts_params)

    case Blogs.create_posts(post_with_slug) do
      {:ok, posts} ->
        notify_parent({:saved, posts})

        {:noreply,
         socket
         |> put_flash(:info, "Posts created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp slug_from_title(post) do
    slug =
      post["title"]
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/, "-")
      |> String.replace(~r/^-+|-+$/, "")

    post |> Map.put("slug", slug)
  end
end
