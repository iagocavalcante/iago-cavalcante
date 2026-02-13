%{
  title: "Shared Context: What RFCs Assume and Agents Need to Hear",
  author: "Iago Cavalcante",
  tags: ~w(ai software-engineering rfcs prompts agents development),
  description: "RFCs assume the reader knows the project. Agents know nothing. Externalizing implicit context is the difference between perfect code in the wrong architecture and code that actually fits.",
  locale: "en",
  published: false,
  scheduled_for: ~D[2026-04-02]
}
---

Hey folks! Today I'm opening with a story I've seen happen more than once -- and that you might recognize.

**The code was perfect. The architecture was wrong.**

A developer asked an agent to create an order processing module. The prompt was clear: "Create an order processing service with validation, price calculation, and customer notification." The agent delivered clean code. Tests passing. Well-chosen names. Best practices followed to the letter.

Except the entire project used event sourcing. And the agent built a classic CRUD with synchronous calls, direct database updates, and mutable state. Impeccable code. Completely wrong paradigm.

The problem wasn't a lack of skill from the agent. It was a lack of context.

## The context nobody writes down

In any engineering team that has worked together for a while, there's an invisible layer of shared knowledge. When someone on the team writes an RFC saying "use our standard error handling," everyone understands what that means. Nobody needs to explain that "standard error handling" means tagged tuples `{:ok, result} | {:error, reason}`, logging via Logger, returning 4xx for client errors and 5xx for server errors.

When the RFC says "follow the pattern from the payments module," the team knows that means: separate context, distinct creation changeset from update changeset, cross-context references via simple ID field instead of `belongs_to`. Nobody needs to spell it out. Everyone was in the meeting. Everyone read the pull request. Everyone has been breathing this code for months.

This shared knowledge is what makes RFCs work so well within teams. They can be concise precisely because the reader already carries a ton of implicit context.

The problem? Agents weren't in the meeting. They didn't read the pull request. They haven't been breathing the code for months. They have **zero shared context.**

## The five categories of invisible context

Across multiple projects with agents, I've identified five categories of context that teams assume are obvious but that agents need to hear explicitly.

### 1. Tech stack and libraries

Seems basic, but it's not. "Create an API" could result in Express, FastAPI, Phoenix, Spring Boot, or any other framework. The agent will choose whatever seems most likely given the prompt -- and it can miss badly.

Saying the language isn't enough. State the framework, the key libraries, and the relevant version when it matters. "Elixir with Phoenix 1.7, Ecto for persistence, Oban for async jobs" is very different from just "Elixir."

### 2. Naming conventions

Does your team use `snake_case` or `camelCase` for API fields? Do modules follow `MyApp.Context.Entity` or `MyApp.Entity.Context`? Do tests live in `test/context/entity_test.exs` or `test/entity_test.exs`?

These conventions seem trivial, but when the agent generates code with a different convention than the project uses, the result is that "something feels off" sensation that eats up review time. The code works, but it doesn't fit.

### 3. Architectural patterns

This is the category from the opening example. REST vs. event sourcing. Monolith vs. microservices. MVC vs. context-based. Synchronous calls vs. message queues. Active Record vs. Repository pattern.

If the agent doesn't know which pattern the project follows, it will choose the most conventional one. And "the most conventional" isn't always what your project uses. Perfect code, wrong paradigm.

### 4. Project modules and infrastructure

Every mature project has its internal modules. Sanitizers, caches, task supervisors, spam detectors, authentication helpers. The agent doesn't know they exist.

If your project has a configured `TaskSupervisor` and the agent uses `Task.start/1` (fire-and-forget), the code works but violates an important architectural decision. If there's a `Sanitizer` for null bytes and the agent doesn't use it in a changeset, you've introduced a vulnerability.

### 5. Business domain language

Is "order" the same as "purchase"? Is "client" different from "user"? How many steps does "approval" have? Does "published" mean visible to everyone or just to subscribers?

Domain language is perhaps the most subtle category. The agent might use synonyms that make sense in common language but create confusion in code. If the entire project uses "booking" and the agent generates code with "reservation," you have a consistency problem that spreads fast.

## When context is missing: anatomy of a silent disaster

Let's go back to the order processing example and break down what happened.

The prompt said:

```
Create an order processing service.
Validate order data.
Calculate total price with discounts.
Notify customer when the order is confirmed.
```

The agent delivered:

```elixir
defmodule MyApp.Orders do
  def create_order(attrs) do
    %Order{}
    |> Order.changeset(attrs)
    |> calculate_total()
    |> Repo.insert()
    |> notify_customer()
  end
end
```

Clean code, right? But the project used event sourcing. What was expected looked more like:

```elixir
defmodule MyApp.Orders.CommandHandler do
  def handle(%CreateOrder{} = command) do
    order = Order.new(command.order_id)

    order
    |> Order.validate(command)
    |> Order.apply_discounts(command.discount_codes)
    |> Order.emit_event(%OrderCreated{})
  end
end
```

See the difference? It's not a question of code quality. Both snippets are well written. The difference is paradigm. The first is imperative, synchronous, with direct side effects. The second is event-based, with separate commands and handlers. Both are "correct" -- but only one of them fits the project.

The agent had no way to know. Nobody told it.

## The CLAUDE.md pattern: externalizing context

This is where an idea comes in that I consider fundamental for anyone working with agents professionally: **externalize the team's implicit context into a persistent document.**

The name can vary. CLAUDE.md, AGENTS.md, system-context.md, .cursorrules -- the name matters less than the habit. The idea is to create a document containing everything the team knows but never wrote down.

A good context document covers those five categories I mentioned:

```markdown
## Stack and Libraries
- Elixir 1.16 with Phoenix 1.7
- Ecto for persistence, PostgreSQL
- Oban for async jobs
- Swoosh with Resend for emails
- Tailwind CSS with dark mode

## Naming Conventions
- Contexts follow MyApp.ContextName (e.g., Iagocavalcante.Accounts)
- Schemas live inside contexts: Iagocavalcante.Accounts.User
- Tests in test/iagocavalcante/context_test.exs

## Architectural Patterns
- Context-based architecture: business logic separated into contexts
- Cross-context references via simple ID field, NOT belongs_to
- Separate changesets per operation: create_changeset, update_changeset
- Ecto.Enum with atoms for status fields

## Project Modules
- Iagocavalcante.Ecto.Sanitizer: null byte sanitization
- Iagocavalcante.TaskSupervisor: supervised async tasks
- Iagocavalcante.Bookmarks.Cache: ETS cache for bookmarks

## Security (CRITICAL)
- Sanitize ALL user input against null bytes
- Validate paths against path traversal
- NEVER use Task.start/1 -- always Task.Supervisor.start_child
```

When the agent has access to this document, it doesn't need to guess. It knows the project uses separate contexts, that references are via simple ID, that there's a Sanitizer that needs to be used. The code it generates isn't just correct -- it fits.

## The bonus nobody expected

Here's something I didn't anticipate when I started working with context documents: **they help humans too.**

Think about onboarding a new team member. How long does it take for that person to understand the project's conventions? Where the modules are? What the patterns are? What should never be done?

Normally, this knowledge is transmitted by osmosis. Pair programming, code reviews, Slack questions, and that classic "oh, we don't do it that way here, we do it this way." It works, but it's slow and depends on the availability of whoever already knows.

A well-written context document accelerates this process dramatically. The new member reads the document and in 30 minutes has a clear picture of the project's conventions, constraints, and patterns. It doesn't replace pair programming -- but it provides a foundation that makes all other interactions more productive.

It's the same principle that Pragmatic Engineer discusses when talking about how RFC processes capture institutional knowledge. The documentation you create to align agents ends up becoming living documentation that aligns the entire team. The effort of externalizing context for machines forces you to articulate things that were always implicit -- and that articulation benefits everyone.

## How to start: three practical steps

If the idea makes sense but seems like a lot of work, here's an incremental path:

**Step 1: Start with what hurts.** When was the last time an agent generated code that "worked but was wrong"? Write down what was missing. Stack? Pattern? Convention? Start documenting that.

**Step 2: Evolve with mistakes.** Every time the agent gets something wrong due to missing context, add the missing information to the document. Within a few weeks, you'll have a robust document built from real problems.

**Step 3: Review with the team.** Share the document. Ask: "what's missing?" Colleagues will point out contexts you didn't even realize were implicit. This exercise of collective externalization is valuable in itself.

The document never gets "done." It evolves with the project. And that's fine -- the point isn't perfection, it's having a place where context lives explicitly instead of only in people's heads.

## What's coming next

Now we have all the pieces: RFC structure, explicit constraints, interfaces, acceptance criteria, feedback loops, and shared context. In the next article, we'll bring it all together. We'll talk about **the unified document** -- how to combine RFC discipline with prompt flexibility into an artifact that serves both to align the team and to instruct agents.

---

### Series: RFCs as Prompts for AI-Agent Development

1. [The fundamental connection](/blog/the-rfc-nobody-read-and-the-prompt-nobody-wrote)
2. [Anatomy of a good RFC](/blog/the-anatomy-of-a-good-rfc)
3. [Anatomy of a good system prompt](/blog/the-anatomy-of-a-good-system-prompt)
4. [Explicit constraints — The power of "don't do this"](/blog/explicit-constraints-the-power-of-dont-do-this)
5. [Interfaces and contracts](/blog/interfaces-and-contracts)
6. [Acceptance criteria](/blog/acceptance-criteria)
7. [Feedback loops](/blog/where-the-prompt-goes-beyond-the-rfc)
8. **Shared context** *(this article)*
9. The unified document *(coming soon)*
10. The future of specification *(coming soon)*

---

Enjoyed this? Want to discuss how to externalize context in your projects? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).
