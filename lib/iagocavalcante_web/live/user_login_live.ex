defmodule IagocavalcanteWeb.UserLoginLive do
  use IagocavalcanteWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.simple_form
        :let={f}
        id="login_form"
        for={:user}
        action={~p"/admin/login"}
        as={:user}
        phx-update="ignore"
      >
        <.input field={{f, :email}} type="email" label="Email" required />
        <.input field={{f, :password}} type="password" label="Senha" required />

        <:actions :let={f}>
          <.input field={{f, :remember_me}} type="checkbox" label="Mantenha-me logado" />
          <.link href={~p"/esqueceu_senha"} class="text-sm font-semibold">
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
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{email: email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
