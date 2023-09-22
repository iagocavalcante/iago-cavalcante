defmodule Iagocavalcante.Blog.SubscriberNotifier do
  import Swoosh.Email
  import IagocavalcanteWeb.Gettext

  alias Iagocavalcante.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Iago Cavalcante", "contato@iagocavalcante.company"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm subscription.
  """
  def deliver_confirmation_subscription(subscriber, url) do
    deliver(subscriber.email, "Confirmation instructions", """

    ==============================

    Hi #{subscriber.email},

    You can confirm your subscription by visiting the URL below:

    #{url}

    If you didn't subscribe with us, please ignore this.

    ==============================
    """)
  end
end
