defmodule Iagocavalcante.Subscribers do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Iagocavalcante.Repo

  alias Iagocavalcante.Blog.Subscriber
  alias Iagocavalcante.Blog.SubscriberNotifier

  @doc """
  Returns the list of subscriber.

  ## Examples

      iex> list_subscriber()
      [%Subscriber{}, ...]

  """
  def list_subscriber do
    Repo.all(Subscriber)
  end

  def list_last_subscriber do
    Repo.all(from p in Subscriber, order_by: [desc: p.inserted_at], limit: 3)
  end

  def already_subscribed?(email) do
    query = from(s in Subscriber, where: s.email == ^email)
    Repo.exists?(query)
  end

  @doc """
  Gets a single subscriber.

  Raises `Ecto.NoResultsError` if the Subscriber does not exist.

  ## Examples

      iex> get_subscriber!(123)
      %Subscriber{}

      iex> get_subscriber!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscriber!(id), do: Repo.get!(Subscriber, id)

  def get_by_email!(email),
    do: from(s in Subscriber, where: s.email == ^email and is_nil(s.verified_at)) |> Repo.one()

  def get_by_token(token),
    do: from(s in Subscriber, where: s.token == ^token and is_nil(s.verified_at)) |> Repo.one()

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

  def verify_subscriber(socket, token) do
    subscriber = get_by_token(token)

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
