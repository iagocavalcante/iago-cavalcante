defmodule Iagocavalcante.Subscribers do
  @moduledoc """
  The Subscribers context for managing newsletter subscriptions.

  Handles subscriber creation, verification, and notification delivery.
  """

  import Ecto.Query, warn: false
  alias Iagocavalcante.Repo

  alias Iagocavalcante.Blog.Subscriber
  alias Iagocavalcante.Blog.SubscriberNotifier

  @doc """
  Returns all subscribers.

  ## Examples

      iex> list_subscribers()
      [%Subscriber{}, ...]

  """
  def list_subscribers do
    Repo.all(Subscriber)
  end

  # Deprecated: Use list_subscribers/0 instead
  def list_subscriber, do: list_subscribers()

  @doc """
  Returns the most recent subscribers.
  """
  def list_recent_subscribers(limit \\ 3) do
    from(s in Subscriber, order_by: [desc: s.inserted_at], limit: ^limit)
    |> Repo.all()
  end

  # Deprecated: Use list_recent_subscribers/1 instead
  def list_last_subscriber, do: list_recent_subscribers(3)

  @doc """
  Returns all verified subscribers.
  """
  def list_verified_subscribers do
    from(s in Subscriber, where: not is_nil(s.verified_at))
    |> Repo.all()
  end

  @doc """
  Returns the count of verified subscribers.
  """
  def count_verified_subscribers do
    from(s in Subscriber, where: not is_nil(s.verified_at))
    |> Repo.aggregate(:count)
  end

  @doc """
  Checks if an email is already subscribed.
  """
  def already_subscribed?(email) do
    from(s in Subscriber, where: s.email == ^email)
    |> Repo.exists?()
  end

  @doc """
  Gets a subscriber by ID. Returns `{:ok, subscriber}` or `{:error, :not_found}`.
  """
  def get_subscriber(id) do
    case Repo.get(Subscriber, id) do
      nil -> {:error, :not_found}
      subscriber -> {:ok, subscriber}
    end
  end

  @doc """
  Gets a subscriber by ID. Raises `Ecto.NoResultsError` if not found.
  """
  def get_subscriber!(id), do: Repo.get!(Subscriber, id)

  @doc """
  Gets an unverified subscriber by email.
  Returns the subscriber or nil.
  """
  def get_unverified_by_email(email) do
    from(s in Subscriber, where: s.email == ^email and is_nil(s.verified_at))
    |> Repo.one()
  end

  # Deprecated: naming inconsistent (has ! but returns nil)
  def get_by_email!(email), do: get_unverified_by_email(email)

  @doc """
  Gets an unverified subscriber by token.
  Returns the subscriber or nil.
  """
  def get_unverified_by_token(token) do
    from(s in Subscriber, where: s.token == ^token and is_nil(s.verified_at))
    |> Repo.one()
  end

  # Deprecated: Use get_unverified_by_token/1 instead
  def get_by_token(token), do: get_unverified_by_token(token)

  @doc """
  Creates a subscriber.

  ## Examples

      iex> create_subscriber(%{field: value})
      {:ok, %Subscriber{}}

      iex> create_subscriber(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscriber(attrs \\ %{}) do
    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscriber.

  ## Examples

      iex> update_subscriber(subscriber, %{field: new_value})
      {:ok, %Subscriber{}}

      iex> update_subscriber(subscriber, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscriber(%Subscriber{} = subscriber, attrs) do
    subscriber
    |> Subscriber.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscriber.

  ## Examples

      iex> delete_subscriber(subscriber)
      {:ok, %Subscriber{}}

      iex> delete_subscriber(subscriber)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscriber(%Subscriber{} = subscriber) do
    Repo.delete(subscriber)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscriber changes.

  ## Examples

      iex> change_subscriber(subscriber)
      %Ecto.Changeset{data: %Subscriber{}}

  """
  def change_subscriber(%Subscriber{} = subscriber, attrs \\ %{}) do
    Subscriber.changeset(subscriber, attrs)
  end

  @doc """
  Verifies a subscriber using a token.

  Returns `{:ok, subscriber}` on success, `{:ok, :already_verified}` if already verified,
  or `{:error, :invalid_token}` if token is invalid or expired.
  """
  def verify_subscriber(socket, token) do
    subscriber = get_unverified_by_token(token)

    if is_nil(subscriber) do
      {:ok, :already_verified}
    else
      case Phoenix.Token.verify(socket, subscriber.email, token, max_age: 86400) do
        {:ok, _subscriber} ->
          subscriber
          |> change_subscriber(%{verified_at: DateTime.utc_now()})
          |> Repo.update()

        {:error, _} ->
          {:error, :invalid_token}
      end
    end
  end

  @doc """
  Sends new post notifications synchronously (legacy).
  """
  def notify_new_post(post_params) do
    subscribers = list_verified_subscribers()

    Enum.chunk_every(subscribers, 50)
    |> Enum.each(fn chunk ->
      Enum.each(chunk, fn subscriber ->
        SubscriberNotifier.deliver_new_post(subscriber.email, post_params)
      end)
    end)
  end

  @doc """
  Sends new post notifications asynchronously with progress updates.

  Sends progress updates to the LiveView component via send_update.
  """
  def notify_new_post_async(post_params, liveview_pid, component_id) do
    subscribers = list_verified_subscribers()
    total = length(subscribers)

    result =
      subscribers
      |> Enum.with_index(1)
      |> Enum.reduce(%{sent: 0, failed: 0}, fn {subscriber, index}, acc ->
        case SubscriberNotifier.deliver_new_post(subscriber.email, post_params) do
          {:ok, _} ->
            new_acc = %{acc | sent: acc.sent + 1}

            # Send progress update every 5 emails or on the last one
            if rem(index, 5) == 0 or index == total do
              send_progress_update(liveview_pid, component_id, %{
                sent: new_acc.sent,
                failed: new_acc.failed,
                status: :sending
              })
            end

            new_acc

          {:error, _} ->
            new_acc = %{acc | failed: acc.failed + 1}

            if rem(index, 5) == 0 or index == total do
              send_progress_update(liveview_pid, component_id, %{
                sent: new_acc.sent,
                failed: new_acc.failed,
                status: :sending
              })
            end

            new_acc
        end
      end)

    # Send final status
    final_status = if result.failed > 0, do: :error, else: :completed

    send_progress_update(liveview_pid, component_id, %{
      sent: result.sent,
      failed: result.failed,
      status: final_status
    })

    result
  end

  defp send_progress_update(liveview_pid, component_id, progress) do
    send(
      liveview_pid,
      {:update_notification_progress, component_id, progress}
    )
  end

  def deliver_confirmation_subscription(%Subscriber{} = subscriber, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if subscriber.verified_at do
      {:error, :already_confirmed}
    else
      SubscriberNotifier.deliver_confirmation_subscription(
        subscriber,
        confirmation_url_fun.(subscriber.token)
      )
    end
  end
end
