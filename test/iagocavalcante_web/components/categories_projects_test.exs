defmodule IagocavalcanteWeb.CategoriesProjectsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias IagocavalcanteWeb.CategoriesProjects

  defp render_in(locale) do
    Gettext.put_locale(IagocavalcanteWeb.Gettext, locale)
    render_component(&CategoriesProjects.categories_projects/1, %{})
  end

  test "lists the apps with their download pages" do
    html = render_in("en")

    assert html =~ "MiseSnag"
    assert html =~ "https://apps.apple.com/app/id6795595576"
    assert html =~ "https://play.google.com/store/apps/details?id=com.iagocavalcante.fitlock"
    assert html =~ "Download Fitlock on Google Play"
  end

  test "translates the section to pt_BR" do
    html = render_in("pt_BR")

    assert html =~ "Projetos de clientes"
    assert html =~ "lista de compras"
    assert html =~ "Baixar LeafTok na App Store"
    refute html =~ "grocery list"
  end
end
