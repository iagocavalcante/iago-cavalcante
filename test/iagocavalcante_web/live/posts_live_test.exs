defmodule IagocavalcanteWeb.PostsLiveTest do
  use IagocavalcanteWeb.ConnCase

  import Phoenix.LiveViewTest
  import Iagocavalcante.BlogFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_posts(_) do
    posts = post_fixture()
    %{posts: posts}
  end

  describe "Index" do
    setup [:create_posts]

    test "lists all posts", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/posts")

      assert html =~ "Listing Posts"
    end

    test "saves new posts", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      assert index_live |> element("a", "New Posts") |> render_click() =~
               "New Posts"

      assert_patch(index_live, ~p"/posts/new")

      assert index_live
             |> form("#posts-form", posts: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#posts-form", posts: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/posts")

      html = render(index_live)
      assert html =~ "Posts created successfully"
    end

    test "updates posts in listing", %{conn: conn, posts: posts} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      assert index_live |> element("#posts-#{posts.id} a", "Edit") |> render_click() =~
               "Edit Posts"

      assert_patch(index_live, ~p"/posts/#{posts}/edit")

      assert index_live
             |> form("#posts-form", posts: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#posts-form", posts: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/posts")

      html = render(index_live)
      assert html =~ "Posts updated successfully"
    end

    test "deletes posts in listing", %{conn: conn, posts: posts} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      assert index_live |> element("#posts-#{posts.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#posts-#{posts.id}")
    end
  end

  describe "Show" do
    setup [:create_posts]

    test "displays posts", %{conn: conn, posts: posts} do
      {:ok, _show_live, html} = live(conn, ~p"/posts/#{posts}")

      assert html =~ "Show Posts"
    end

    test "updates posts within modal", %{conn: conn, posts: posts} do
      {:ok, show_live, _html} = live(conn, ~p"/posts/#{posts}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Posts"

      assert_patch(show_live, ~p"/posts/#{posts}/show/edit")

      assert show_live
             |> form("#posts-form", posts: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#posts-form", posts: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/posts/#{posts}")

      html = render(show_live)
      assert html =~ "Posts updated successfully"
    end
  end
end
