%{
  title: "The Unified Document: Writing for Humans and Agents at the Same Time",
  author: "Iago Cavalcante",
  tags: ~w(ai software-engineering rfcs prompts agents development),
  description: "A single document that works as an RFC for engineers and as a prompt for agents. It's not a compromise - it's the better version of both.",
  locale: "en",
  published: false,
  scheduled_for: ~D[2026-04-09]
}
---

Hey folks! Nine articles. Two parallel tracks. Today they merge.

Since the very first article, we've been walking through two worlds that seemed separate. On one side, RFCs -- documents that have aligned engineering teams for decades. On the other, prompts -- instructions that guide AI agents. And article after article, one thing became clear: the best practices for one are the best practices for the other.

Clear structure. Explicit constraints. Defined interfaces. Verifiable acceptance criteria. Feedback loops. Shared context. Everything that makes an RFC work for engineers makes a prompt work for agents. The bridge exists. Now it's time to cross it for good.

## Two documents, one problem

In practice, what happens in most teams working with agents? They maintain two separate artifacts.

The RFC goes to the engineering team. It describes the problem, the solution, the architectural decisions, what's out of scope. It's written in prose, assumes shared context, and serves as a decision record.

The prompt goes to the agent. It repeats much of what's in the RFC, but adds technical details that the RFC "doesn't need": exact stack, file paths, code examples, expected output format.

The result? Two documents that say almost the same thing, but with subtle divergences. The RFC says "use the project's standard authentication." The prompt says "use phx_gen_auth with Argon2." When someone updates the RFC but forgets to update the prompt, the agent implements something different from what the team decided. When someone tweaks the prompt but doesn't reflect it in the RFC, the reference document becomes stale.

Two documents = two sources of truth = no source of truth.

## The merger nobody expected

What if there were a single document that served both? That a senior engineer could read and understand the full proposal, and that an AI agent could receive and execute?

It sounds like a compromise. Like you'd have to simplify one side to serve the other. But that's not what happens.

Throughout this series, I noticed something that changed how I write technical documentation: **the information an agent needs is exactly what makes an RFC better for humans.** That's not a coincidence. It's a consequence of a deeper principle.

## What an agent needs that a traditional RFC doesn't have

A traditional RFC works because it assumes context. The reader knows the stack. Knows where the files live. Knows which patterns the team uses. Knows how to run the tests. The RFC doesn't need to say any of this because the reader already knows.

An agent knows none of that.

To work as a prompt, the document needs additions that a traditional RFC omits:

**Explicit stack declaration.** Not "use the project's framework." Yes "Elixir 1.16, Phoenix 1.7, LiveView, PostgreSQL 16, Tailwind CSS."

**File paths.** Not "create the module in the appropriate location." Yes "create `lib/iagocavalcante/bookmarks/bookmark.ex` and `lib/iagocavalcante_web/live/bookmark_live/index.ex`."

**Code examples.** Not "follow the project's pattern." Yes, a code snippet showing how the pattern applies to this case.

**Executable test expectations.** Not "should have tests." Yes "the test should verify that `Bookmarks.create_bookmark/1` returns `{:ok, %Bookmark{}}` with valid attributes."

**Output format.** Not "return the bookmark data." Yes, the exact JSON or struct that should be returned.

And here's the crucial point: **none of these additions hurt human readability.** In fact, they improve it.

## Writing for agents makes you a better writer for humans

Remember the junior dev who joined the team last week? They also don't know what "the project's standard authentication" is. They also don't know where "the appropriate location" is. They also need an example to understand the pattern.

When you write an RFC with the precision an agent demands, you're writing an RFC that anyone on the team can follow -- not just those who were in the alignment meeting, not just those who already know the codebase by heart.

The explicitness that agents demand is the same that makes documents accessible to:

- Junior devs still learning the project
- Devs from other teams who need to contribute occasionally
- You yourself, six months from now, when you've forgotten why you made that decision
- Anyone going through onboarding

The unified document isn't a compromise between two audiences. It's the version that should have been written all along.

## The unified document template

After refining this approach throughout the entire series, I arrived at a template that consistently works for both humans and agents. Each section plays a dual role.

```
# [Feature Title]

## Problem
What's wrong today. Why this needs to be solved.
Why now.

## Context
Where this feature fits in the system. Which previous
decisions influence this one. Links to related RFCs.

## Stack and environment
- Language: Elixir 1.16
- Framework: Phoenix 1.7 with LiveView
- Database: PostgreSQL 16
- CSS: Tailwind CSS 3.4
- Tests: ExUnit with async: true

## Proposed solution
Description of the chosen approach. Why this one and
not another. Accepted trade-offs.

## Constraints
- DO NOT use belongs_to across contexts (use field :user_id, :id)
- DO NOT run queries in LiveView mount/3
- Sanitize inputs against null bytes (use Sanitizer)
- Async tasks via Task.Supervisor

## Non-goals
- What this document does NOT solve
- Related features deferred to later
- Decisions intentionally postponed

## Interface contracts

### Exposed endpoints
GET /api/bookmarks -> list of user's bookmarks
POST /api/bookmarks -> create new bookmark
DELETE /api/bookmarks/:id -> soft delete

### Types
@type bookmark :: %{
  id: integer(),
  url: String.t(),
  title: String.t(),
  user_id: integer(),
  inserted_at: DateTime.t()
}

### Response format
Success (200):
{"data": [bookmark]}

Error (422):
{"error": "validation_failed", "details": [...]}

## Acceptance criteria
- [ ] User can add bookmark with URL and title
- [ ] URL validated (must start with http:// or https://)
- [ ] Duplicate URLs per user return clear error
- [ ] Title limited to 200 characters
- [ ] Soft delete with confirmation
- [ ] Paginated list, 20 per page, newest first
- [ ] User only sees their own bookmarks

## File structure
lib/
  iagocavalcante/
    bookmarks/
      bookmark.ex          # Schema + changesets
      bookmarks.ex         # Context (CRUD)
  iagocavalcante_web/
    live/
      bookmark_live/
        index.ex           # Main LiveView
        form_component.ex  # Form component
test/
  iagocavalcante/
    bookmarks_test.exs     # Context tests
  iagocavalcante_web/
    live/
      bookmark_live_test.exs  # LiveView tests

## Examples

### Schema
defmodule Iagocavalcante.Bookmarks.Bookmark do
  use Ecto.Schema

  schema "bookmarks" do
    field :url, :string
    field :title, :string
    field :user_id, :id
    field :deleted_at, :utc_datetime

    timestamps()
  end
end

### Context
defmodule Iagocavalcante.Bookmarks do
  def list_bookmarks(user_id) do
    Bookmark
    |> where(user_id: ^user_id)
    |> where([b], is_nil(b.deleted_at))
    |> order_by(desc: :inserted_at)
    |> Repo.paginate()
  end
end
```

Look at this template. Now try to separate what's "for the human" from what's "for the agent." You can't. Everything is useful for both. The problem is useful for the human to understand motivation and for the agent to understand context. The acceptance criteria are the team's definition of done and the agent's stop signal. The code examples are reference for the dev and instruction for the agent.

## The unified document in practice: a bookmarks system

To show this isn't theory, I'll use the example we've visited across several articles -- a bookmarks system. Notice how each section of the template fills in naturally.

The **Problem** says why we need bookmarks: users want a way to save content for later. The **Context** says we already have an authentication system and a dashboard where bookmarks will appear. The **Stack** eliminates any ambiguity about technologies. The **Constraints** reinforce project patterns that article 4 taught us to make explicit. The **Contracts** define the interface before implementation, as we saw in article 5. The **Acceptance criteria** are the stop signal from article 6. The **File structure** says exactly where everything goes. The **Examples** show the expected pattern, leaving no room for interpretation.

An engineer reads this and knows what to build, why, and how to validate that it's done.

An agent reads this and has all the information needed to execute.

One document. Two audiences. Zero compromise.

## The maintenance advantage

Beyond the quality of the document itself, the unified model solves an operational problem that few people mention: **maintenance.**

With two separate documents (RFC + prompt), any change needs to be reflected in two places. "We decided to switch from soft delete to hard delete" -- update the RFC, update the prompt. "The endpoint changed from /api/bookmarks to /api/v2/bookmarks" -- update both. "We added a new acceptance criterion" -- update both.

In practice, the second update is almost always delayed or forgotten. And when the two documents diverge, neither is trustworthy.

With the unified document, the change happens in one place. The engineer updating the RFC is automatically updating the prompt. The prompt the agent receives is always the latest version of the team's decision. One source of truth. Always in sync.

## The series map, revisited

Across the previous eight articles, every piece clicked into place:

Article 1 showed that RFCs and prompts solve the same problem -- communicating intent with clarity. Article 2 dissected the RFC's structure. Article 3 mirrored it in the prompt. Article 4 taught us to make constraints explicit. Article 5 defined interface contracts. Article 6 created verifiable acceptance criteria. Article 7 went beyond the RFC with feedback loops. Article 8 brought the context that agents need to hear explicitly.

This article, the ninth, is the synthesis. Each of those elements has a place in the unified document. It's not a forced mixture -- it's the natural fit of pieces that were always part of the same puzzle.

## What's coming next

In the tenth and final article, we look ahead. What happens when the unified document evolves from a static artifact into something that integrates directly with code? When the RFC doesn't describe the system -- it **is** the system? We'll talk about the future of technical specification.

---

### Series: RFCs as Prompts for AI-Agent Development

1. [The fundamental connection](/blog/the-rfc-nobody-read-and-the-prompt-nobody-wrote)
2. [Anatomy of a good RFC](/blog/the-anatomy-of-a-good-rfc)
3. [Anatomy of a good system prompt](/blog/the-anatomy-of-a-good-system-prompt)
4. [Explicit constraints — The power of "don't do this"](/blog/explicit-constraints-the-power-of-dont-do-this)
5. [Interfaces and contracts](/blog/interfaces-and-contracts)
6. [Acceptance criteria](/blog/acceptance-criteria)
7. [Feedback loops](/blog/where-the-prompt-goes-beyond-the-rfc)
8. Shared context *(coming soon)*
9. **The unified document** *(this article)*
10. The future of specification *(coming soon)*

---

Enjoyed this? Want to discuss how to unify your technical documents? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).
