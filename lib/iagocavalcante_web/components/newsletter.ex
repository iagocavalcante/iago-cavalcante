defmodule IagocavalcanteWeb.Newsletter do
  use IagocavalcanteWeb, :live_component
  import IagocavalcanteWeb.Gettext

  alias Iagocavalcante.Blog.Subscriber
  alias Iagocavalcante.Mailer
  alias Iagocavalcante.Subscribers

  def render(assigns) do
    ~H"""
    <form
      for={:subscriber}
      phx-submit="join_newsletter"
      phx-target={@myself}
      class="rounded-2xl border border-zinc-100 p-6 dark:border-zinc-700/40"
    >
      <h2 class="flex text-sm font-semibold text-zinc-900 dark:text-zinc-100">
        <svg
          viewBox="0 0 24 24"
          fill="none"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
          class="h-6 w-6 flex-none"
        >
          <path
            d="M2.75 7.75a3 3 0 0 1 3-3h12.5a3 3 0 0 1 3 3v8.5a3 3 0 0 1-3 3H5.75a3 3 0 0 1-3-3v-8.5Z"
            class="fill-zinc-100 stroke-zinc-400 dark:fill-zinc-100/10 dark:stroke-zinc-500"
          >
          </path>
          <path
            d="m4 6 6.024 5.479a2.915 2.915 0 0 0 3.952 0L20 6"
            class="stroke-zinc-400 dark:stroke-zinc-500"
          >
          </path>
        </svg>
        <span class="ml-3"><%= gettext("Stay up to date", lang: @locale) %></span>
      </h2>
      <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
        <%= gettext("Get notified when I publish something new, and unsubscribe at any time.",
          lang: @locale
        ) %>
      </p>
      <div class="mt-6 flex">
        <input
          type="email"
          placeholder={gettext("Email address", lang: @locale)}
          aria-label="Email address"
          required=""
          id="subscriber_email"
          name={:email}
          class="min-w-0 flex-auto appearance-none rounded-md border border-zinc-900/10 bg-white px-3 py-[calc(theme(spacing.2)-1px)] shadow-md shadow-zinc-800/5 placeholder:text-zinc-400 focus:border-teal-500 focus:outline-none focus:ring-4 focus:ring-teal-500/10 dark:border-zinc-700 dark:bg-zinc-700/[0.15] dark:text-zinc-200 dark:placeholder:text-zinc-500 dark:focus:border-teal-400 dark:focus:ring-teal-400/10 sm:text-sm"
          style="cursor: auto; background-size: 20px 20px !important; background-position: 98% 50% !important; background-repeat: no-repeat !important; background-image: url(&quot;moz-extension://e41bef21-1234-46da-8756-62c40409e30d/Icon-20.png&quot;) !important;"
        />
        <button
          class="inline-flex items-center gap-2 justify-center rounded-md py-2 px-3 text-sm outline-offset-2 transition active:transition-none bg-zinc-800 font-semibold text-zinc-100 hover:bg-zinc-700 active:bg-zinc-800 active:text-zinc-100/70 dark:bg-zinc-700 dark:hover:bg-zinc-600 dark:active:bg-zinc-700 dark:active:text-zinc-100/70 ml-4 flex-none"
          type="submit"
        >
          <%= gettext("Join", lang: @locale) %>
        </button>
      </div>
      <%= if assigns[:error] do %>
        <p class="text-sm mt-2 font-bold text-red-400"><%= assigns[:error] %></p>
      <% end %>
      <%= if assigns[:message] do %>
        <p class="text-sm mt-2 font-bold text-blue-400"><%= assigns[:message] %></p>
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
