defmodule Iagocavalcante.Clients.Cloudflare.API do
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
      }
    )
  end

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
    do_request()
    |> Req.get!(url: "/client/v4/user/tokens/verify")
    |> then(fn response ->
      case response do
        %{status: 200, body: %{"success" => true, "result" => result}} ->
          {:ok, result}

        %{body: %{"errors" => [error | _]}} ->
          {:error, error["message"]}

        _ ->
          {:error, "Failed to verify credentials"}
      end
    end)
  end

  defp list_accounts do
    do_request()
    |> Req.get!(url: "/client/v4/accounts")
    |> then(fn response ->
      case response do
        %{status: 200, body: %{"success" => true, "result" => results}} ->
          {:ok, results}

        %{body: %{"errors" => [error | _]}} ->
          {:error, error["message"]}

        _ ->
          {:error, "Failed to list accounts"}
      end
    end)
  end

  defp auth do
    %{
      base_url: Application.get_env(:iagocavalcante, :cloudflare_base_url),
      token: Application.get_env(:iagocavalcante, :cloudflare_api_token),
      account_id: Application.get_env(:iagocavalcante, :cloudflare_account_id)
    }
  end
end
