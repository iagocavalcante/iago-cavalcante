defmodule Iagocavalcante.BlogTest do
  use Iagocavalcante.DataCase

  alias Iagocavalcante.Blog

  describe "posts" do
    alias Iagocavalcante.Blog.Post

    import Iagocavalcante.BlogFixtures

    @invalid_attrs %{}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Blog.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Blog.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{}

      assert {:ok, %Post{} = post} = Blog.create_post(valid_attrs)
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{}

      assert {:ok, %Post{} = post} = Blog.update_post(post, update_attrs)
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
      assert post == Blog.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Blog.change_post(post)
    end
  end

  describe "posts" do
    alias Iagocavalcante.Blog.Posts

    import Iagocavalcante.BlogFixtures

    @invalid_attrs %{}

    test "list_posts/0 returns all posts" do
      posts = posts_fixture()
      assert Blog.list_posts() == [posts]
    end

    test "get_posts!/1 returns the posts with given id" do
      posts = posts_fixture()
      assert Blog.get_posts!(posts.id) == posts
    end

    test "create_posts/1 with valid data creates a posts" do
      valid_attrs = %{}

      assert {:ok, %Posts{} = posts} = Blog.create_posts(valid_attrs)
    end

    test "create_posts/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_posts(@invalid_attrs)
    end

    test "update_posts/2 with valid data updates the posts" do
      posts = posts_fixture()
      update_attrs = %{}

      assert {:ok, %Posts{} = posts} = Blog.update_posts(posts, update_attrs)
    end

    test "update_posts/2 with invalid data returns error changeset" do
      posts = posts_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_posts(posts, @invalid_attrs)
      assert posts == Blog.get_posts!(posts.id)
    end

    test "delete_posts/1 deletes the posts" do
      posts = posts_fixture()
      assert {:ok, %Posts{}} = Blog.delete_posts(posts)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_posts!(posts.id) end
    end

    test "change_posts/1 returns a posts changeset" do
      posts = posts_fixture()
      assert %Ecto.Changeset{} = Blog.change_posts(posts)
    end
  end
end
