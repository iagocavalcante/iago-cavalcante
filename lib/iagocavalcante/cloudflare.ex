defmodule Iagocavalcante.Cloudflare do
  def req_cloudflare do
    base_url = Application.get_env(:iagocavalcante, :cloudflare_base_url)
    token = Application.get_env(:iagocavalcante, :cloudflare_api_token)
    req = Req.new(base_url: base_url, headers: %{authorization: "Bearer #{token}"})
    req
  end
end
