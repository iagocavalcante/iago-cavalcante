defmodule Iagocavalcante.Clients.Cloudflare.API do
  @moduledoc """
  Base Cloudflare API client with proper timeouts and error handling.
  """

  require Logger

  # Default timeout (30 seconds)
  @default_timeout 30_000

  @doc """
  Creates a new Req request with Cloudflare authentication and default timeouts.

  ## Options

    * `account_id` - Override the default account ID from config
  """
  def do_request(account_id \\ nil) do
    auth = auth()
    account = account_id || auth.account_id

    base_url =
      case account do
        nil -> auth.base_url
        id -> "#{auth.base_url}/client/v4/accounts/#{id}"
      end

    Req.new(
      base_url: base_url,
      headers: %{
        "Authorization" => "Bearer #{auth.token}",
        "Content-Type" => "application/json"
      },
      receive_timeout: @default_timeout
    )
  end

  @doc """
  Checks the Cloudflare API connection by verifying credentials and listing accounts.

  ## Returns

    * `{:ok, %{token_status: ..., accounts: ...}}` - Connection successful
    * `{:error, reason}` - Connection failed
  """
  def check_connection do
    with {:ok, verify_result} <- verify_credentials(),
         {:ok, accounts} <- list_accounts() do
      {
        :ok,
        %{
          token_status: verify_result,
          accounts: accounts
        }
      }
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp verify_credentials do
    request = do_request()

    case Req.get(request, url: "/client/v4/user/tokens/verify") do
      {:ok, %{status: 200, body: %{"success" => true, "result" => result}}} ->
        {:ok, result}

      {:ok, %{body: %{"errors" => [error | _]}}} ->
        Logger.error("Cloudflare credentials verification failed: #{error["message"]}")
        {:error, error["message"]}

      {:ok, %{status: status, body: body}} ->
        Logger.error(
          "Cloudflare credentials verification failed: HTTP #{status}, body: #{inspect(body)}"
        )

        {:error, "Failed to verify credentials (HTTP #{status})"}

      {:error, %Req.TransportError{reason: reason}} ->
        Logger.error("Network error verifying Cloudflare credentials: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}

      {:error, reason} ->
        Logger.error("Error verifying Cloudflare credentials: #{inspect(reason)}")
        {:error, "Failed to verify credentials"}
    end
  end

  defp list_accounts do
    request = do_request()

    case Req.get(request, url: "/client/v4/accounts") do
      {:ok, %{status: 200, body: %{"success" => true, "result" => results}}} ->
        {:ok, results}

      {:ok, %{body: %{"errors" => [error | _]}}} ->
        Logger.error("Failed to list Cloudflare accounts: #{error["message"]}")
        {:error, error["message"]}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to list Cloudflare accounts: HTTP #{status}, body: #{inspect(body)}")
        {:error, "Failed to list accounts (HTTP #{status})"}

      {:error, %Req.TransportError{reason: reason}} ->
        Logger.error("Network error listing Cloudflare accounts: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}

      {:error, reason} ->
        Logger.error("Error listing Cloudflare accounts: #{inspect(reason)}")
        {:error, "Failed to list accounts"}
    end
  end

  defp auth do
    %{
      base_url: Application.get_env(:iagocavalcante, :cloudflare_base_url),
      token: Application.get_env(:iagocavalcante, :cloudflare_api_token),
      account_id: Application.get_env(:iagocavalcante, :cloudflare_account_id)
    }
  end
end
