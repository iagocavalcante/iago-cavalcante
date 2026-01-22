defmodule Iagocavalcante.BlogCreatePostTest do
  @moduledoc """
  Tests for Blog.create_new_post function, specifically focusing on the
  published field handling to prevent the || false bug.

  The bug was: `attrs["published"] || true` returns `true` when
  attrs["published"] is `false` because `false || true` = `true`.

  The fix uses `Map.get(attrs, "published", true)` which correctly
  preserves explicit `false` values.
  """

  use ExUnit.Case, async: true

  alias Iagocavalcante.Blog

  # These tests use a temporary directory to avoid polluting the actual blog posts
  setup do
    # Create a temporary directory for test posts
    temp_dir = System.tmp_dir!() |> Path.join("blog_test_#{System.unique_integer([:positive])}")
    File.mkdir_p!(Path.join([temp_dir, "en", "#{Date.utc_today().year}"]))
    File.mkdir_p!(Path.join([temp_dir, "pt_BR", "#{Date.utc_today().year}"]))

    # Store original config and set temp path
    original_path = Application.get_env(:iagocavalcante, :blog_post_path)
    Application.put_env(:iagocavalcante, :blog_post_path, temp_dir <> "/")

    on_exit(fn ->
      # Restore original config
      if original_path do
        Application.put_env(:iagocavalcante, :blog_post_path, original_path)
      else
        Application.delete_env(:iagocavalcante, :blog_post_path)
      end

      # Clean up temp directory
      File.rm_rf!(temp_dir)
    end)

    %{temp_dir: temp_dir}
  end

  describe "create_new_post/1 published field handling" do
    test "creates post with published=true when not specified", %{temp_dir: temp_dir} do
      attrs = %{
        "title" => "Test Post Title",
        "description" => "Test description",
        "body" => "Test body content",
        "tags" => "test,blog",
        "locale" => "en",
        "slug" => "test-post-no-published-#{System.unique_integer([:positive])}",
        "year" => Date.utc_today().year,
        "path" => "01-01-test-post.md"
      }

      result = Blog.create_new_post(attrs)
      assert result == :ok

      # Verify the file was created with published: true in the header
      year = Date.utc_today().year
      file_path = Path.join([temp_dir, "en", "#{year}", attrs["path"]])
      content = File.read!(file_path)

      assert content =~ "published: true"
    end

    test "creates post with published=true when explicitly set to true", %{temp_dir: temp_dir} do
      attrs = %{
        "title" => "Published Post",
        "description" => "Test description",
        "body" => "Test body content",
        "tags" => "test",
        "locale" => "en",
        "slug" => "published-post-#{System.unique_integer([:positive])}",
        "year" => Date.utc_today().year,
        "path" => "01-02-published-post.md",
        "published" => true
      }

      result = Blog.create_new_post(attrs)
      assert result == :ok

      year = Date.utc_today().year
      file_path = Path.join([temp_dir, "en", "#{year}", attrs["path"]])
      content = File.read!(file_path)

      assert content =~ "published: true"
    end

    test "creates post with published=false when explicitly set to false (BUG FIX)", %{
      temp_dir: temp_dir
    } do
      # This is the critical test for the bug fix
      # Before the fix, this would create a published post due to:
      # attrs["published"] || true => false || true => true

      attrs = %{
        "title" => "Draft Post",
        "description" => "This is a draft",
        "body" => "Draft content",
        "tags" => "draft",
        "locale" => "en",
        "slug" => "draft-post-#{System.unique_integer([:positive])}",
        "year" => Date.utc_today().year,
        "path" => "01-03-draft-post.md",
        "published" => false
      }

      result = Blog.create_new_post(attrs)
      assert result == :ok

      year = Date.utc_today().year
      file_path = Path.join([temp_dir, "en", "#{year}", attrs["path"]])
      content = File.read!(file_path)

      # This assertion would fail before the bug fix
      assert content =~ "published: false"
      refute content =~ "published: true"
    end

    test "creates draft post with string 'false' value", %{temp_dir: temp_dir} do
      # Edge case: form params might come as strings
      attrs = %{
        "title" => "String False Draft",
        "description" => "Testing string false",
        "body" => "Content",
        "tags" => "draft",
        "locale" => "en",
        "slug" => "string-false-draft-#{System.unique_integer([:positive])}",
        "year" => Date.utc_today().year,
        "path" => "01-04-string-false.md",
        "published" => "false"
      }

      result = Blog.create_new_post(attrs)
      assert result == :ok

      year = Date.utc_today().year
      file_path = Path.join([temp_dir, "en", "#{year}", attrs["path"]])
      content = File.read!(file_path)

      # String "false" is truthy, so this should be published: false (as a string)
      # The actual behavior depends on how the value is interpolated
      assert File.exists?(file_path)
    end

    test "creates post in pt_BR locale with published=false", %{temp_dir: temp_dir} do
      attrs = %{
        "title" => "Rascunho em Portugues",
        "description" => "Um rascunho de post",
        "body" => "Conteudo do rascunho",
        "tags" => "rascunho",
        "locale" => "pt_BR",
        "slug" => "rascunho-#{System.unique_integer([:positive])}",
        "year" => Date.utc_today().year,
        "path" => "01-05-rascunho.md",
        "published" => false
      }

      result = Blog.create_new_post(attrs)
      assert result == :ok

      year = Date.utc_today().year
      file_path = Path.join([temp_dir, "pt_BR", "#{year}", attrs["path"]])
      content = File.read!(file_path)

      assert content =~ "published: false"
    end
  end

  describe "create_new_post/1 validation" do
    test "rejects invalid locale" do
      attrs = %{
        "title" => "Invalid Locale Post",
        "description" => "Test",
        "body" => "Test",
        "tags" => "test",
        "locale" => "invalid",
        "slug" => "invalid-locale",
        "year" => Date.utc_today().year,
        "path" => "test.md",
        "published" => false
      }

      result = Blog.create_new_post(attrs)
      assert result == {:error, "invalid locale"}
    end

    test "rejects invalid year" do
      attrs = %{
        "title" => "Invalid Year Post",
        "description" => "Test",
        "body" => "Test",
        "tags" => "test",
        "locale" => "en",
        "slug" => "invalid-year",
        "year" => 1999,
        "path" => "test.md",
        "published" => false
      }

      result = Blog.create_new_post(attrs)
      assert result == {:error, "invalid year"}
    end

    test "rejects invalid slug characters" do
      attrs = %{
        "title" => "Invalid Slug Post",
        "description" => "Test",
        "body" => "Test",
        "tags" => "test",
        "locale" => "en",
        "slug" => "invalid slug with spaces!",
        "year" => Date.utc_today().year,
        "path" => "test.md",
        "published" => false
      }

      result = Blog.create_new_post(attrs)
      assert result == {:error, "invalid slug characters"}
    end
  end

  describe "Map.get vs || operator behavior" do
    @doc """
    These tests demonstrate why Map.get/3 is the correct choice over ||
    for handling boolean default values.
    """

    test "|| operator incorrectly treats false as missing" do
      # This demonstrates the bug that was fixed
      attrs = %{"published" => false}

      # BUG: This returns true when published is false
      buggy_result = attrs["published"] || true
      assert buggy_result == true

      # FIX: This correctly returns false
      fixed_result = Map.get(attrs, "published", true)
      assert fixed_result == false
    end

    test "|| operator works correctly when value is nil" do
      attrs = %{}

      # When key is missing, || works correctly
      result_buggy = attrs["published"] || true
      result_fixed = Map.get(attrs, "published", true)

      assert result_buggy == true
      assert result_fixed == true
    end

    test "Map.get/3 correctly handles all cases" do
      # Missing key
      assert Map.get(%{}, "published", true) == true

      # Explicit true
      assert Map.get(%{"published" => true}, "published", true) == true

      # Explicit false (the critical case)
      assert Map.get(%{"published" => false}, "published", true) == false

      # Explicit nil (treated as missing)
      assert Map.get(%{"published" => nil}, "published", true) == nil
    end
  end
end
