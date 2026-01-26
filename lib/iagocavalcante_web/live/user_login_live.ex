defmodule IagocavalcanteWeb.UserLoginLive do
  use IagocavalcanteWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.simple_form
        for={@form}
        id="login_form"
        action={~p"/admin/login"}
        phx-update="ignore"
      >
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Senha" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Mantenha-me logado" />
          <.link href={~p"/admin/reset_password"} class="text-sm font-semibold">
            Esqueceu sua senha?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Entre <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{email: email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
