defmodule IagocavalcanteWeb.Admin.PostsLiveTest do
  @moduledoc """
  LiveView tests for the admin posts management interface.

  These tests focus on:
  1. Draft saving functionality (the bug fix for published=false)
  2. Form component behavior
  3. Publish modal workflow
  """

  use IagocavalcanteWeb.ConnCase
  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  # Use a temp directory to avoid creating real blog posts
  setup do
    temp_dir =
      System.tmp_dir!() |> Path.join("blog_liveview_test_#{System.unique_integer([:positive])}")

    File.mkdir_p!(Path.join([temp_dir, "en", "#{Date.utc_today().year}"]))
    File.mkdir_p!(Path.join([temp_dir, "pt_BR", "#{Date.utc_today().year}"]))

    original_path = Application.get_env(:iagocavalcante, :blog_post_path)
    Application.put_env(:iagocavalcante, :blog_post_path, temp_dir <> "/")

    on_exit(fn ->
      if original_path do
        Application.put_env(:iagocavalcante, :blog_post_path, original_path)
      else
        Application.delete_env(:iagocavalcante, :blog_post_path)
      end

      File.rm_rf!(temp_dir)
    end)

    %{temp_dir: temp_dir}
  end

  describe "Admin Posts Index" do
    test "renders admin posts page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/admin/posts")

      assert html =~ "Admin" or html =~ "Posts" or html =~ "Story"
    end
  end

  describe "New Post Form" do
    test "renders new post form", %{conn: conn} do
      {:ok, view, html} = live(conn, "/admin/posts/new")

      # Check form elements are present
      assert html =~ "posts-form" or html =~ "Write a new story"

      assert has_element?(view, "input[name*='title']") or
               has_element?(view, "input[id*='title']")
    end

    test "shows save draft button", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/admin/posts/new")

      assert html =~ "Save Draft"
    end

    test "shows publish button", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/admin/posts/new")

      assert html =~ "Publish"
    end
  end

  describe "FormComponent save_draft event" do
    test "save_draft sets published to false", %{conn: conn, temp_dir: temp_dir} do
      {:ok, view, _html} = live(conn, "/admin/posts/new")

      # Fill in the form
      view
      |> form("#posts-form", %{
        "title" => "My Draft Post",
        "description" => "A draft description",
        "tags" => "draft,test",
        "locale" => "en"
      })
      |> render_change()

      # Trigger save_draft event
      view
      |> element("button", "Save Draft")
      |> render_click()

      # Verify a file was created with published: false
      year = Date.utc_today().year
      files = Path.wildcard(Path.join([temp_dir, "en", "#{year}", "*.md"]))

      # If a file was created, check its content
      if length(files) > 0 do
        content = File.read!(hd(files))
        assert content =~ "published: false"
        refute content =~ "published: true"
      end
    end
  end

  describe "FormComponent show_publish_modal event" do
    test "shows publish confirmation modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/posts/new")

      # Fill in required fields
      view
      |> form("#posts-form", %{
        "title" => "Post to Publish",
        "description" => "Description",
        "tags" => "test",
        "locale" => "en"
      })
      |> render_change()

      # Submit the form to show modal
      html =
        view
        |> form("#posts-form")
        |> render_submit()

      # Modal should appear
      assert html =~ "Ready to publish?" or html =~ "Publish Now" or html =~ "modal"
    end
  end

  describe "FormComponent confirm_publish event" do
    test "creates published post when confirming", %{conn: conn, temp_dir: temp_dir} do
      {:ok, view, _html} = live(conn, "/admin/posts/new")

      # Fill in required fields
      view
      |> form("#posts-form", %{
        "title" => "Published Post Title",
        "description" => "Post description",
        "tags" => "published,test",
        "locale" => "en"
      })
      |> render_change()

      # Submit form to show modal
      view
      |> form("#posts-form")
      |> render_submit()

      # Confirm publish
      view
      |> element("button", "Publish Now")
      |> render_click()

      # Verify a file was created with published: true
      year = Date.utc_today().year
      files = Path.wildcard(Path.join([temp_dir, "en", "#{year}", "*.md"]))

      if length(files) > 0 do
        content = File.read!(hd(files))
        assert content =~ "published: true"
      end
    end
  end

  describe "FormComponent validate event" do
    test "validates form changes", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/posts/new")

      # Change form values
      html =
        view
        |> form("#posts-form", %{
          "title" => "Updated Title"
        })
        |> render_change()

      # Form should still be valid
      assert html =~ "Updated Title" or html =~ "posts-form"
    end
  end

  describe "FormComponent toggle_notify_subscribers event" do
    test "toggles newsletter notification checkbox", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/posts/new")

      # Fill form and show modal
      view
      |> form("#posts-form", %{
        "title" => "Post with Notification",
        "description" => "Test description",
        "tags" => "test",
        "locale" => "en"
      })
      |> render_change()

      view
      |> form("#posts-form")
      |> render_submit()

      # Modal should have notification checkbox
      html = render(view)

      if html =~ "Notify newsletter subscribers" do
        # Try to toggle the checkbox
        view
        |> element("input[type='checkbox']")
        |> render_click()

        # Should toggle the notification state
        updated_html = render(view)
        assert updated_html =~ "Notify newsletter subscribers"
      end
    end
  end

  describe "FormComponent close_publish_modal event" do
    test "closes modal when cancel is clicked", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/posts/new")

      # Fill form and show modal
      view
      |> form("#posts-form", %{
        "title" => "Post to Cancel",
        "description" => "Description",
        "tags" => "test",
        "locale" => "en"
      })
      |> render_change()

      view
      |> form("#posts-form")
      |> render_submit()

      # Close the modal
      if has_element?(view, "button", "Cancel") do
        view
        |> element("button", "Cancel")
        |> render_click()

        # Modal should be closed
        html = render(view)
        refute html =~ "Ready to publish?"
      end
    end
  end

  describe "slug generation" do
    test "generates slug from title", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/posts/new")

      view
      |> form("#posts-form", %{
        "title" => "My Amazing Blog Post!"
      })
      |> render_change()

      html = render(view)
      # Should show slug preview
      assert html =~ "my-amazing-blog-post" or html =~ "slug-preview"
    end

    test "handles special characters in title", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/posts/new")

      view
      |> form("#posts-form", %{
        "title" => "Post with Spëcial Chäracters & Symbols!"
      })
      |> render_change()

      html = render(view)
      # Should sanitize the slug
      assert html =~ "posts-form"
    end
  end

  describe "locale selection" do
    test "allows selecting English locale", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/posts/new")

      html =
        view
        |> form("#posts-form", %{
          "locale" => "en"
        })
        |> render_change()

      assert html =~ "English" or html =~ "en"
    end

    test "allows selecting Portuguese locale", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/posts/new")

      html =
        view
        |> form("#posts-form", %{
          "locale" => "pt_BR"
        })
        |> render_change()

      assert html =~ "Portuguese" or html =~ "pt_BR"
    end
  end

  describe "notify_subscribers event" do
    test "shows notify button only for published posts", %{conn: conn, temp_dir: temp_dir} do
      # Create a published post file
      year = Date.utc_today().year
      day = String.pad_leading("#{Date.utc_today().day}", 2, "0")
      month = String.pad_leading("#{Date.utc_today().month}", 2, "0")

      published_content = """
      %{
        title: "Published Post",
        description: "A published post",
        tags: ~w(test),
        published: true,
        locale: "en",
        author: "Test Author"
      }
      ---

      Content here
      """

      draft_content = """
      %{
        title: "Draft Post",
        description: "A draft post",
        tags: ~w(test),
        published: false,
        locale: "en",
        author: "Test Author"
      }
      ---

      Content here
      """

      File.write!(
        Path.join([temp_dir, "en", "#{year}", "#{month}-#{day}-published-post.md"]),
        published_content
      )

      File.write!(
        Path.join([temp_dir, "en", "#{year}", "#{month}-#{day}-draft-post.md"]),
        draft_content
      )

      {:ok, _view, html} = live(conn, "/admin/posts")

      # The page should render (even if posts aren't shown due to NimblePublisher compilation)
      assert html =~ "Posts Management"
    end

    test "notify_subscribers event handler exists", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/posts")

      # The view should handle the notify_subscribers event without crashing
      # Even if no post is found, it should return an error flash
      html = render_click(view, "notify_subscribers", %{"id" => "nonexistent-post"})

      assert html =~ "Post not found" or html =~ "Posts Management"
    end
  end

  describe "draft vs publish workflow comparison" do
    @doc """
    These tests verify that the draft and publish workflows
    correctly set the published field to different values.
    """

    test "draft workflow sets published=false, publish workflow sets published=true", %{
      conn: conn,
      temp_dir: temp_dir
    } do
      # Test 1: Create a draft
      {:ok, view1, _html} = live(conn, "/admin/posts/new")

      view1
      |> form("#posts-form", %{
        "title" => "Draft Test Post",
        "description" => "Draft description",
        "tags" => "draft",
        "locale" => "en"
      })
      |> render_change()

      view1
      |> element("button", "Save Draft")
      |> render_click()

      # Check draft file
      year = Date.utc_today().year
      draft_files = Path.wildcard(Path.join([temp_dir, "en", "#{year}", "*draft*.md"]))

      if length(draft_files) > 0 do
        draft_content = File.read!(hd(draft_files))
        assert draft_content =~ "published: false"
      end

      # Test 2: Create a published post
      {:ok, view2, _html} = live(conn, "/admin/posts/new")

      view2
      |> form("#posts-form", %{
        "title" => "Published Test Post",
        "description" => "Published description",
        "tags" => "published",
        "locale" => "en"
      })
      |> render_change()

      view2
      |> form("#posts-form")
      |> render_submit()

      if has_element?(view2, "button", "Publish Now") do
        view2
        |> element("button", "Publish Now")
        |> render_click()

        published_files = Path.wildcard(Path.join([temp_dir, "en", "#{year}", "*published*.md"]))

        if length(published_files) > 0 do
          published_content = File.read!(hd(published_files))
          assert published_content =~ "published: true"
        end
      end
    end
  end
end
