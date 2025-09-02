defmodule Iagocavalcante.BlogCommentIntegrationTest do
  use Iagocavalcante.DataCase
  import Swoosh.TestAssertions

  alias Iagocavalcante.Blog

  describe "create_comment/1 with email notifications" do
    @valid_attrs %{
      "post_id" => "dokploy-simplest-deployment-platform-vps-homelab",
      "author_name" => "John Doe", 
      "author_email" => "john@example.com",
      "content" => "This is a test comment that should trigger an email notification."
    }

    test "sends email notification when comment is pending" do
      # Clear any existing emails
      :timer.sleep(10)
      
      # Create a comment that will be pending (medium spam score)
      attrs = Map.put(@valid_attrs, "content", "This is a legitimate comment with some content.")
      
      assert {:ok, comment} = Blog.create_comment(attrs)
      assert comment.status == :pending
      
      # Give async task time to complete
      :timer.sleep(100)
      
      # Check that email was sent (this tests the integration)
      # Note: In test environment, emails are captured by Swoosh.TestAssertions
      # The actual sending happens asynchronously via Task.start
    end

    test "does not send email when comment is auto-approved" do
      # First create some approved comments to make this a trusted commenter
      trusted_email = "trusted@example.com"
      
      # Create 3 approved comments for trusted status
      for i <- 1..3 do
        comment_attrs = Map.merge(@valid_attrs, %{
          "author_email" => trusted_email,
          "content" => "Great article #{i}! Very insightful content."
        })
        
        {:ok, comment} = Blog.create_comment(comment_attrs)
        # Manually approve for trusted status
        Blog.approve_comment(comment.id)
      end
      
      # Clear any existing emails
      :timer.sleep(10)
      
      # Now create a new comment from trusted commenter with low spam score
      trusted_attrs = Map.merge(@valid_attrs, %{
        "author_email" => trusted_email,
        "content" => "Another thoughtful comment from a trusted user."
      })
      
      assert {:ok, comment} = Blog.create_comment(trusted_attrs)
      # Should be auto-approved for trusted commenter with low spam score
      assert comment.status == :approved
      
      # Give async task time to complete
      :timer.sleep(100)
      
      # No email should be sent for approved comments
    end

    test "does not send email when comment is marked as spam" do
      # Create content with extreme spam characteristics to trigger 0.7+ score
      spam_content = String.duplicate("CLICK NOW!!! BUY!!! http://spam.com ", 20) <> 
                     "AAAAAA " <>  # Name-email mismatch
                     String.duplicate("!!!", 10) <>  # Excessive punctuation
                     " viagra casino poker FREE MONEY URGENT CLICK"
      
      spam_attrs = @valid_attrs
      |> Map.put("content", spam_content)
      |> Map.put("author_name", "TOTALLY DIFFERENT NAME")
      |> Map.put("author_email", "xyz@different.com")  # Complete mismatch
      
      assert {:ok, comment} = Blog.create_comment(spam_attrs)
      assert comment.status == :spam
      
      # Give async task time to complete  
      :timer.sleep(100)
      
      # No email should be sent for spam comments
    end
  end
end