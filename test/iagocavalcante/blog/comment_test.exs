defmodule Iagocavalcante.Blog.CommentTest do
  use Iagocavalcante.DataCase

  alias Iagocavalcante.Blog.Comment

  describe "changeset/2" do
    @valid_attrs %{
      "post_id" => "test-post",
      "author_name" => "John Doe",
      "author_email" => "john@example.com",
      "content" => "This is a great post! Thank you for sharing your insights."
    }

    test "changeset with valid attributes" do
      changeset = Comment.changeset(%Comment{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset requires post_id" do
      attrs = Map.delete(@valid_attrs, "post_id")
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "can't be blank" in errors_on(changeset).post_id
    end

    test "changeset requires author_name" do
      attrs = Map.delete(@valid_attrs, "author_name")
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "can't be blank" in errors_on(changeset).author_name
    end

    test "changeset requires author_email" do
      attrs = Map.delete(@valid_attrs, "author_email")
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "can't be blank" in errors_on(changeset).author_email
    end

    test "changeset requires content" do
      attrs = Map.delete(@valid_attrs, "content")
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "can't be blank" in errors_on(changeset).content
    end

    test "changeset validates email format" do
      attrs = Map.put(@valid_attrs, "author_email", "invalid-email")
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "must be a valid email" in errors_on(changeset).author_email
    end

    test "changeset validates author_name length" do
      attrs = Map.put(@valid_attrs, "author_name", "A")
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "should be at least 2 character(s)" in errors_on(changeset).author_name

      attrs = Map.put(@valid_attrs, "author_name", String.duplicate("A", 51))
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "should be at most 50 character(s)" in errors_on(changeset).author_name
    end

    test "changeset validates content length" do
      attrs = Map.put(@valid_attrs, "content", "Short")
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "should be at least 10 character(s)" in errors_on(changeset).content

      attrs = Map.put(@valid_attrs, "content", String.duplicate("A", 2001))
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "should be at most 2000 character(s)" in errors_on(changeset).content
    end

    test "changeset validates status inclusion" do
      attrs = Map.put(@valid_attrs, "status", "invalid_status")
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "is invalid" in errors_on(changeset).status
    end

    test "changeset validates spam_score range" do
      attrs = Map.put(@valid_attrs, "spam_score", -0.1)
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "must be greater than or equal to 0.0" in errors_on(changeset).spam_score

      attrs = Map.put(@valid_attrs, "spam_score", 1.1)
      changeset = Comment.changeset(%Comment{}, attrs)
      assert "must be less than or equal to 1.0" in errors_on(changeset).spam_score
    end

    test "changeset sets default status to pending" do
      changeset = Comment.changeset(%Comment{}, @valid_attrs)
      assert Ecto.Changeset.get_field(changeset, :status) == :pending
    end

    test "changeset sets default spam_score to 0.0" do
      changeset = Comment.changeset(%Comment{}, @valid_attrs)
      assert Ecto.Changeset.get_field(changeset, :spam_score) == 0.0
    end
  end

  describe "spam detection" do
    test "calculates higher spam score for excessive links" do
      content =
        "Check out these links: https://spam1.com https://spam2.com https://spam3.com https://spam4.com https://spam5.com"

      attrs = Map.put(@valid_attrs, "content", content)
      changeset = Comment.changeset(%Comment{}, attrs)
      spam_score = Ecto.Changeset.get_field(changeset, :spam_score)
      assert spam_score > 0.2
    end

    test "calculates higher spam score for suspicious keywords" do
      content =
        "Buy cheap discount viagra and get free money from our casino! This amazing offer won't last long!"

      attrs = Map.put(@valid_attrs, "content", content)
      changeset = Comment.changeset(%Comment{}, attrs)
      spam_score = Ecto.Changeset.get_field(changeset, :spam_score)
      assert spam_score > 0.1
    end

    test "calculates higher spam score for name-email mismatch" do
      attrs =
        @valid_attrs
        |> Map.put("author_name", "John Smith")
        |> Map.put("author_email", "xyz123@example.com")

      changeset = Comment.changeset(%Comment{}, attrs)
      spam_score = Ecto.Changeset.get_field(changeset, :spam_score)
      assert spam_score > 0.0
    end

    test "calculates higher spam score for poor content quality" do
      content = "GREAT POST!!!"
      attrs = Map.put(@valid_attrs, "content", content)
      changeset = Comment.changeset(%Comment{}, attrs)
      spam_score = Ecto.Changeset.get_field(changeset, :spam_score)
      assert spam_score > 0.0
    end

    test "calculates lower spam score for legitimate content" do
      content =
        "Thank you for this insightful article. I particularly found the section about testing strategies very helpful for my current project."

      attrs =
        @valid_attrs
        |> Map.put("author_name", "Jane Doe")
        |> Map.put("author_email", "jane.doe@company.com")
        |> Map.put("content", content)

      changeset = Comment.changeset(%Comment{}, attrs)
      spam_score = Ecto.Changeset.get_field(changeset, :spam_score)
      assert spam_score < 0.1
    end
  end

  describe "status functions" do
    test "approved_statuses/0 returns correct statuses" do
      assert Comment.approved_statuses() == [:approved]
    end

    test "pending_statuses/0 returns correct statuses" do
      assert Comment.pending_statuses() == [:pending]
    end

    test "spam_statuses/0 returns correct statuses" do
      assert Comment.spam_statuses() == [:spam, :rejected]
    end
  end
end
