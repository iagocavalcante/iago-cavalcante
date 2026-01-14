defmodule Iagocavalcante.Blog.CommentApprovalPolicy do
  @moduledoc """
  Policy module for determining comment approval status.

  Separates business rules from context implementation for better testability
  and clearer separation of concerns.
  """

  @doc """
  Determines the appropriate status for a comment based on spam score
  and whether the commenter is trusted.

  ## Rules
  - spam_score >= 0.7 → :spam (high risk)
  - spam_score <= 0.3 and trusted → :approved (auto-approve trusted users)
  - otherwise → :pending (manual review required)

  ## Examples

      iex> determine_status(%{spam_score: 0.8}, false)
      :spam

      iex> determine_status(%{spam_score: 0.2}, true)
      :approved

      iex> determine_status(%{spam_score: 0.5}, false)
      :pending
  """
  @spec determine_status(map(), boolean()) :: :spam | :approved | :pending
  def determine_status(%{spam_score: spam_score}, trusted_commenter?) do
    cond do
      spam_score >= 0.7 -> :spam
      spam_score <= 0.3 and trusted_commenter? -> :approved
      true -> :pending
    end
  end

  @doc """
  Threshold for considering a commenter as trusted.
  """
  @spec trusted_threshold() :: pos_integer()
  def trusted_threshold, do: 3

  @doc """
  Spam score threshold for auto-marking as spam.
  """
  @spec spam_threshold() :: float()
  def spam_threshold, do: 0.7

  @doc """
  Spam score threshold for auto-approval eligibility.
  """
  @spec safe_threshold() :: float()
  def safe_threshold, do: 0.3
end
