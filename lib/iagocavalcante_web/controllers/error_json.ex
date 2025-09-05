defmodule IagocavalcanteWeb.ErrorJSON do
  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render("401.json", _assigns) do
    %{error: "Authentication required"}
  end

  def render("403.json", _assigns) do
    %{error: "Access forbidden"}
  end

  def render("404.json", _assigns) do
    %{error: "Resource not found"}
  end

  def render("422.json", _assigns) do
    %{error: "Unprocessable entity"}
  end

  def render("429.json", _assigns) do
    %{error: "Too many requests"}
  end

  def render("500.json", _assigns) do
    %{error: "Internal server error"}
  end

  def render(template, _assigns) do
    %{error: Phoenix.Controller.status_message_from_template(template)}
  end
end
