defmodule IagocavalcanteWeb.Plugs.RateLimiter do
  import Plug.Conn
  require Logger

  @bucket_name :comment_rate_limiter
  @max_requests 5
  # 5 minutes
  @window_seconds 300

  def init(opts), do: opts

  def call(conn, _opts) do
    client_ip = get_client_ip(conn)
    key = "comment_rate_limit:#{client_ip}"

    case check_rate_limit(key) do
      :ok ->
        conn

      :rate_limited ->
        conn
        |> put_status(:too_many_requests)
        |> Phoenix.Controller.put_format(:html)
        |> Phoenix.Controller.render(IagocavalcanteWeb.ErrorHTML, :"429")
        |> halt()
    end
  end

  defp check_rate_limit(key) do
    case :ets.lookup(@bucket_name, key) do
      [] ->
        # First request from this IP
        create_bucket()
        :ets.insert(@bucket_name, {key, 1, :os.system_time(:second)})
        :ok

      [{^key, count, timestamp}] ->
        current_time = :os.system_time(:second)

        if current_time - timestamp > @window_seconds do
          # Window expired, reset counter
          :ets.insert(@bucket_name, {key, 1, current_time})
          :ok
        else
          if count >= @max_requests do
            :rate_limited
          else
            # Increment counter
            :ets.insert(@bucket_name, {key, count + 1, timestamp})
            :ok
          end
        end
    end
  end

  defp create_bucket do
    unless :ets.whereis(@bucket_name) != :undefined do
      :ets.new(@bucket_name, [:set, :public, :named_table])
    end
  end

  defp get_client_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [forwarded_ip | _] ->
        forwarded_ip
        |> String.split(",")
        |> List.first()
        |> String.trim()

      [] ->
        conn.remote_ip
        |> :inet.ntoa()
        |> to_string()
    end
  end
end
