defmodule IagocavalcanteWeb.Nav do
  import Phoenix.LiveView
  use Phoenix.Component

  alias IagocavalcanteWeb.{HomeLive}

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:active_tab, :handle_params, &handle_active_tab_params/3)}
  end

  defp handle_active_tab_params(params, _url, socket) do
    IO.inspect(socket.assigns.live_action)

    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {HomeLive, _} ->
          :home

        {_, _} ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end

  defp handle_event(_, _, socket), do: {:cont, socket}
end
