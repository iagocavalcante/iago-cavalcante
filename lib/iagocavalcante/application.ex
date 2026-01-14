defmodule Iagocavalcante.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      IagocavalcanteWeb.Telemetry,
      # Start the Ecto repository
      Iagocavalcante.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Iagocavalcante.PubSub},
      # Start DNSCluster for DNS resolution
      {DNSCluster, query: Application.get_env(:iagocavalcante, :dns_cluster_query) || :ignore},
      # Start Finch
      {Finch, name: Iagocavalcante.Finch},
      # Task supervisor for async operations (email notifications, etc.)
      {Task.Supervisor, name: Iagocavalcante.TaskSupervisor},
      # Bookmarks cache for CSV data
      Iagocavalcante.Bookmarks.Cache,
      # Start the Endpoint (http/https)
      IagocavalcanteWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Iagocavalcante.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IagocavalcanteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
