defmodule IagocavalcanteWeb.HeaderTest do
  use ExUnit.Case, async: true
  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias IagocavalcanteWeb.Header
  alias IagocavalcanteWeb.NavItem

  describe "header/1" do
    test "renders mobile menu button" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Header.header>
          <:nav_items>
            <NavItem.nav_item link="/about" text="About" active_item={:about} />
          </:nav_items>
          <:toggle_items>
            <div>Toggle</div>
          </:toggle_items>
        </Header.header>
        """)

      assert html =~ "mobile-menu-button"
      assert html =~ "mobile-menu-dropdown"
      assert html =~ "toggleMobileMenu()"
      assert html =~ "About"
    end

    test "renders mobile menu backdrop" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Header.header>
          <:nav_items>
            <NavItem.nav_item link="/articles" text="Articles" active_item={:home} />
          </:nav_items>
          <:toggle_items>
            <div>Toggle</div>
          </:toggle_items>
        </Header.header>
        """)

      assert html =~ "mobile-menu-backdrop"
      assert html =~ "closeMobileMenu()"
    end

    test "renders JavaScript functions for mobile menu" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Header.header>
          <:nav_items>
            <NavItem.nav_item link="/projects" text="Projects" active_item={:projects} />
          </:nav_items>
          <:toggle_items>
            <div>Toggle</div>
          </:toggle_items>
        </Header.header>
        """)

      assert html =~ "function toggleMobileMenu()"
      assert html =~ "function closeMobileMenu()"
      assert html =~ "aria-expanded"
    end
  end
end
