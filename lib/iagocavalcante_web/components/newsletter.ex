defmodule IagocavalcanteWeb.Newsletter do
  use IagocavalcanteWeb, :live_component
  use Gettext, backend: IagocavalcanteWeb.Gettext

  alias Iagocavalcante.Subscribers

  def render(assigns) do
    ~H"""
    <form
      for={:subscriber}
      phx-submit="join_newsletter"
      phx-target={@myself}
      class="editorial-card"
    >
      <h2 class="flex items-center text-sm font-mono uppercase tracking-wider text-muted mb-4">
        <svg
          viewBox="0 0 24 24"
          fill="none"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
          class="h-5 w-5 flex-none stroke-current"
        >
          <path d="M2.75 7.75a3 3 0 0 1 3-3h12.5a3 3 0 0 1 3 3v8.5a3 3 0 0 1-3 3H5.75a3 3 0 0 1-3-3v-8.5Z">
          </path>
          <path d="m4 6 6.024 5.479a2.915 2.915 0 0 0 3.952 0L20 6"></path>
        </svg>
        <span class="ml-3">{gettext("Stay up to date", lang: @locale)}</span>
      </h2>
      <p class="text-sm text-ink-light leading-relaxed">
        {gettext("Get notified when I publish something new, and unsubscribe at any time.",
          lang: @locale
        )}
      </p>
      <div class="mt-6 flex">
        <input
          type="email"
          placeholder={gettext("Email address", lang: @locale)}
          aria-label="Email address"
          required=""
          id="subscriber_email"
          name={:email}
          class="editorial-input flex-auto"
        />
        <button
          class="btn-primary ml-4 flex-none"
          type="submit"
        >
          {gettext("Join", lang: @locale)}
        </button>
      </div>
      <%= if assigns[:error] do %>
        <p class="text-sm mt-3 font-medium text-red-600 dark:text-red-400">{assigns[:error]}</p>
      <% end %>
      <%= if assigns[:message] do %>
        <p class="text-sm mt-3 font-medium text-accent">{assigns[:message]}</p>
      <% end %>
    </form>
    """
  end

  def handle_event("join_newsletter", %{"email" => email}, socket) do
    valid_email = Regex.match?(~r/^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/, email)

    if !valid_email do
      {:noreply, assign(socket, :error, "invalid email")}
    end

    if Subscribers.already_subscribed?(email) do
      subscriber = Subscribers.get_by_email!(email)

      {:ok, _email} =
        Subscribers.deliver_confirmation_subscription(
          subscriber,
          &url(~p"/subscribers/confirm/#{&1}")
        )

      {:noreply, assign(socket, :message, "check your email")}
    end

    token = Phoenix.Token.sign(IagocavalcanteWeb.Endpoint, email, email)
    IO.inspect(token)

    case Subscribers.create_subscriber(%{email: email, token: token}) do
      {:ok, subscriber} ->
        {:ok, _email} =
          Subscribers.deliver_confirmation_subscription(
            subscriber,
            &url(~p"/subscribers/confirm/#{&1}")
          )

        {:noreply, assign(socket, :message, "email subscribed")}

      {:error, _changeset} ->
        {:noreply, assign(socket, :error, "email not subscribed")}
    end
  end
end
