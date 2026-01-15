defmodule IagocavalcanteWeb.AdminNav do
  import Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    ff_donate = Application.get_env(:iagocavalcante, :ff_donate, "0") || "0"
    ff_video = Application.get_env(:iagocavalcante, :ff_video, "0") || "0"

    {:cont,
     socket
     |> assign(:locale, maybe_locale(socket))
     |> assign(:active_tab, nil)
     |> assign(:ff, %{
       donate: String.to_integer(ff_donate),
       video: String.to_integer(ff_video)
     })}
  end

  defp maybe_locale(socket) do
    case socket.assigns[:locale] do
      nil -> "en"
      _ -> socket.assigns.locale
    end
  end
end
