defmodule IagocavalcanteWeb.UserSessionController do
  use IagocavalcanteWeb, :controller

  alias Iagocavalcante.Accounts
  alias IagocavalcanteWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/admin/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/admin/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  def set_locale(conn, %{"locale_form" => %{"locale" => locale}}) do
    referer =
      conn
      |> get_req_header("referer")
      |> List.first()

    redirect_to =
      referer
      |> String.split("/", parts: 4)
      |> Enum.at(3)

    conn
    |> put_resp_cookie(@locale_cookie, %{locale: locale}, @locale_options)
    |> redirect(to: "/#{redirect_to}")
  end
end
