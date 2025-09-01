defmodule IagocavalcanteWeb.Plugs.RateLimiterTest do
  use IagocavalcanteWeb.ConnCase
  alias IagocavalcanteWeb.Plugs.RateLimiter

  describe "rate limiting" do
    setup do
      # Clean up any existing ETS table
      if :ets.whereis(:comment_rate_limiter) != :undefined do
        :ets.delete(:comment_rate_limiter)
      end
      :ok
    end

    test "allows requests under the limit" do
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", "192.168.1.1")
      
      # First request should go through
      result_conn = RateLimiter.call(conn, [])
      
      refute result_conn.halted
      assert result_conn.status == nil
    end

    test "blocks requests over the limit from same IP" do
      ip = "192.168.1.2"
      
      # Make 5 requests (the limit)
      for _ <- 1..5 do
        conn = build_conn(:post, "/test", %{})
        |> put_req_header("x-forwarded-for", ip)
        
        result_conn = RateLimiter.call(conn, [])
        refute result_conn.halted
      end
      
      # 6th request should be blocked
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", ip)
      
      result_conn = RateLimiter.call(conn, [])
      
      assert result_conn.halted
      assert result_conn.status == 429
    end

    test "allows requests from different IPs" do
      # Make 5 requests from first IP
      for i <- 1..5 do
        conn = build_conn(:post, "/test", %{})
        |> put_req_header("x-forwarded-for", "192.168.1.#{i}")
        
        result_conn = RateLimiter.call(conn, [])
        refute result_conn.halted
      end
      
      # Request from different IP should still work
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", "192.168.1.10")
      
      result_conn = RateLimiter.call(conn, [])
      refute result_conn.halted
    end

    test "resets counter after window expires" do
      ip = "192.168.1.3"
      
      # Make 5 requests to reach the limit
      for _ <- 1..5 do
        conn = build_conn(:post, "/test", %{})
        |> put_req_header("x-forwarded-for", ip)
        
        RateLimiter.call(conn, [])
      end
      
      # Verify we're at the limit
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", ip)
      
      result_conn = RateLimiter.call(conn, [])
      assert result_conn.halted
      
      # Simulate time passing by manually updating the ETS table
      key = "comment_rate_limit:#{ip}"
      expired_time = :os.system_time(:second) - 301  # 301 seconds ago
      :ets.insert(:comment_rate_limiter, {key, 5, expired_time})
      
      # New request should work after window expires
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", ip)
      
      result_conn = RateLimiter.call(conn, [])
      refute result_conn.halted
    end

    test "handles multiple forwarded IPs correctly" do
      # Test with multiple forwarded IPs (takes first one)
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", "10.0.0.1, 192.168.1.1, 172.16.0.1")
      
      result_conn = RateLimiter.call(conn, [])
      refute result_conn.halted
      
      # Verify it's using the first IP for rate limiting
      # Make 4 more requests with same forwarded-for header
      for _ <- 1..4 do
        conn = build_conn(:post, "/test", %{})
        |> put_req_header("x-forwarded-for", "10.0.0.1, 192.168.1.1, 172.16.0.1")
        
        result_conn = RateLimiter.call(conn, [])
        refute result_conn.halted
      end
      
      # 6th request should be blocked
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", "10.0.0.1, 192.168.1.1, 172.16.0.1")
      
      result_conn = RateLimiter.call(conn, [])
      assert result_conn.halted
    end

    test "falls back to remote_ip when no x-forwarded-for header" do
      # Create connection without x-forwarded-for header
      conn = build_conn(:post, "/test", %{})
      |> Map.put(:remote_ip, {127, 0, 0, 1})
      
      # Make 5 requests
      for _ <- 1..5 do
        result_conn = RateLimiter.call(conn, [])
        refute result_conn.halted
      end
      
      # 6th request should be blocked
      result_conn = RateLimiter.call(conn, [])
      assert result_conn.halted
      assert result_conn.status == 429
    end

    test "creates ETS table if it doesn't exist" do
      # Ensure table doesn't exist
      if :ets.whereis(:comment_rate_limiter) != :undefined do
        :ets.delete(:comment_rate_limiter)
      end
      
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", "192.168.1.100")
      
      # Table should be created on first request
      result_conn = RateLimiter.call(conn, [])
      
      refute result_conn.halted
      assert :ets.whereis(:comment_rate_limiter) != :undefined
    end

    test "handles IP address extraction correctly" do
      # Test with whitespace in forwarded-for header
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", "  192.168.1.5  , 10.0.0.1  ")
      
      result_conn = RateLimiter.call(conn, [])
      refute result_conn.halted
      
      # Verify the same trimmed IP is rate limited
      for _ <- 1..4 do
        conn = build_conn(:post, "/test", %{})
        |> put_req_header("x-forwarded-for", "192.168.1.5")
        
        result_conn = RateLimiter.call(conn, [])
        refute result_conn.halted
      end
      
      # Should be blocked on 6th request
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", "192.168.1.5")
      
      result_conn = RateLimiter.call(conn, [])
      assert result_conn.halted
    end

    test "renders 429 error page when rate limited" do
      ip = "192.168.1.99"
      
      # Reach the limit
      for _ <- 1..5 do
        conn = build_conn(:post, "/test", %{})
        |> put_req_header("x-forwarded-for", ip)
        
        RateLimiter.call(conn, [])
      end
      
      # Next request should return 429
      conn = build_conn(:post, "/test", %{})
      |> put_req_header("x-forwarded-for", ip)
      
      result_conn = RateLimiter.call(conn, [])
      
      assert result_conn.halted
      assert result_conn.status == 429
      # Note: The actual response body would be rendered by the ErrorHTML module
    end
  end

  describe "init/1" do
    test "returns passed options unchanged" do
      opts = [some: :option]
      assert RateLimiter.init(opts) == opts
    end
  end
end