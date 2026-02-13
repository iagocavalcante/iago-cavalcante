%{
  title: "Explicit Constraints: The Power of 'Don't Do This'",
  author: "Iago Cavalcante",
  tags: ~w(ai software-engineering rfcs prompts agents development),
  description: "The most underrated section of any RFC is 'out of scope'. For AI agents, it's the difference between a useful result and three hours of rework.",
  locale: "en",
  published: false,
  scheduled_for: ~D[2026-03-05]
}
---

Hey folks! I want to start today with a story I guarantee will sound familiar.

You ask an AI agent: **"Create a user profile page."** Simple, direct, to the point. Half an hour later, you look at the result and discover you've received a full identity management system.

There's avatar upload with crop and resize. Email verification with automatic resend. Notification preferences with granular toggles. Change history with visual diffs. There's even a Gravatar integration nobody asked for.

You wanted a page with name, email, and bio. You got a mini-SaaS.

## Why does this happen?

When a human gets that same request, their first reaction is to ask questions. "Profile with what? Which fields? Can the user edit it? Do we need a photo? Any integrations?" The dev asks because they have enough experience to know that "profile page" can mean fifty different things.

The agent doesn't ask. It doesn't have that instinct. When it gets a request without boundaries, it fills the void with what it considers most likely — and "most likely" for a model trained on millions of repositories is "everything I've ever seen in profile pages, all at once."

This isn't a bug. It's the expected behavior when you don't define limits.

## The section nobody values

In any well-written RFC, there's a section most people skip: **Non-goals** (or "Out of scope").

It's the most underrated section of any design document. And, ironically, it's the most powerful.

When you write "This RFC does NOT cover social authentication," you're doing something that looks passive but is actually active. You're eliminating an entire category of decisions, implementations, discussions, and bugs. You're telling everyone involved: don't spend brain cycles on this right now.

For humans, this section prevents scope creep — that phenomenon where the project grows little by little until it becomes a monster. For AI agents, it prevents something equivalent: **feature hallucination** — when the agent invents features nobody asked for because the prompt didn't say not to.

## "Don't do" is stronger than "do"

This is a counter-intuitive principle, but think about it with me.

If I say "create a profile page with name, email, and bio," the agent has a direction. But the temptation to add "improvements" is still there. It might think: "well, if there's email, it makes sense to have email verification. And if there's a profile, it makes sense to have an avatar." The feature list grows by association.

Now compare that with this:

```
Create a user profile page.

Do NOT implement:
- Avatar upload
- Email verification
- Notification preferences
- Integration with external services
- Change history
```

The second version is surgical. It doesn't eliminate just one wrong answer — it eliminates entire categories of wrong answers. Each "DO NOT" is a fence the agent won't jump.

Saying "do X" defines one path. Saying "do NOT do Y" eliminates a hundred wrong paths at once.

## The boundary tax

I call this the **"boundary tax"** — the cost you pay when you don't define limits upfront.

Without explicit constraints, what happens is predictable:

1. The agent delivers something bigger than what was asked
2. You spend time evaluating what's useful and what's noise
3. You ask it to remove the unwanted parts
4. The agent removes them, but sometimes breaks other things in the process
5. You spend more time debugging the side effects

The total time of this cycle is almost always greater than the time you'd have spent writing three lines of constraints in the original prompt. It's an invisible tax, but a very real one.

Compare that with the opposite scenario: five minutes defining what's out of scope, clean result on the first try. The math works out every time.

## Constraints in practice: before and after

Let's look at a complete example. Imagine you're building a user profile service in a Phoenix application.

**Before — the prompt without boundaries:**

```
Create a user profile context in Elixir/Phoenix with the necessary
fields and CRUD functions.
```

What the agent will likely deliver: a schema with 15 fields, avatar upload via S3, complex email validations with confirmation sending, a followers system, privacy settings, and maybe even a GenServer cache nobody asked for.

**After — the prompt with explicit constraints:**

```
Create a user profile context in Elixir/Phoenix.

## Fields
- display_name (string, required, max 100 chars)
- bio (text, optional, max 500 chars)
- website (string, optional, validate URL format)
- user_id (reference, required)

## Features
- Basic CRUD (create, read, update, delete)
- Changeset with validations for the fields above

## Out of scope — Do NOT implement
- Image/avatar upload or processing
- Email verification or confirmation
- Followers or social connections system
- Notification preferences
- Cache or performance optimizations
- Seeds or example data
- Tests (I'll write them separately)

## Technical constraints
- Use the Phoenix contexts pattern
- user_id as a plain field (:id), no belongs_to
- Sanitize inputs against null bytes (use the project's Sanitizer module)
```

The difference is dramatic. The second prompt will generate exactly what you need. No surprises, no cleanup, no rework.

## How to write good constraints

After months of working with AI agents using this approach, I've developed a mental template that works well:

**1. List what the agent will want to add.** Think about the "obvious" features a dev (or model) would associate with what you're asking. If you're requesting a contact form, the agent will want to add CAPTCHA, rate limiting, email templates, delivery confirmation.

**2. Be explicit about each one.** A vague "keep it simple" isn't enough. Say exactly what's excluded. "Do NOT add CAPTCHA. Do NOT implement rate limiting. Do NOT create email templates."

**3. Explain why when it's non-obvious.** If the constraint seems strange without context, add a short justification. "Do NOT use belongs_to — contexts are independent in this project." This prevents the agent from "correcting" your constraint because it thinks it's a mistake.

**4. Separate scope constraints from technical constraints.** "Out of scope" is what shouldn't exist. "Technical constraints" is how what exists should be built. Mixing the two confuses both humans and agents.

**5. Use list format.** Long paragraphs of constraints get lost in the prompt. Lists with "DO NOT" in caps are impossible to ignore — for both readers and processors.

## The pattern: constraints as guardrails, not limitations

Something it took me a while to understand is that well-written constraints don't limit the agent — they **free** the agent.

It sounds like a paradox, but it makes sense. When the agent knows exactly what not to do, it can focus all its capacity on what it should. Without constraints, it spends "energy" (tokens, attention) deciding whether it should or shouldn't add each auxiliary feature. With clear constraints, that decision is already made.

It's the same logic as guardrails on a mountain road. They don't exist to limit the driver — they exist so the driver can drive with confidence, knowing that if they drift a little, something prevents the catastrophe.

Your constraints are the agent's guardrails.

## What's coming next

In the next article, we'll talk about **interfaces and contracts** — how to define boundaries between components in a way that makes the agent respect your system's architecture. If constraints say what not to do, interfaces say how the pieces connect.

---

### Series: RFCs as Prompts for AI-Agent Development

1. [The fundamental connection](/blog/the-rfc-nobody-read-and-the-prompt-nobody-wrote)
2. Anatomy of a good RFC *(coming soon)*
3. Anatomy of a good system prompt *(coming soon)*
4. **Explicit constraints — The power of "don't do this"** *(this article)*
5. Interfaces and contracts *(coming soon)*
6. Acceptance criteria *(coming soon)*
7. Feedback loops *(coming soon)*
8. Shared context *(coming soon)*
9. The unified document *(coming soon)*
10. The future of specification *(coming soon)*

---

Enjoyed this? Want to discuss or disagree? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).
