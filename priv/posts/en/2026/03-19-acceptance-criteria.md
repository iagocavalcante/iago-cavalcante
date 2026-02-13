%{
  title: "Acceptance Criteria: When the Agent Knows It's Done",
  author: "Iago Cavalcante",
  tags: ~w(ai software-engineering rfcs prompts agents development),
  description: "Without clear acceptance criteria, the agent doesn't know when to stop. The result is gold-plating or incomplete delivery - the same problems humans have, amplified.",
  locale: "en",
  published: false,
  scheduled_for: ~D[2026-03-19]
}
---

Hey folks! When is a feature done? Ask five devs, get seven answers.

One says it's done when the code compiles. Another says it's done when it has tests. The third says it's done when it passes code review. The fourth says it's done when it's in production. The fifth says it's never truly done, opens a beer, and changes the subject.

Now imagine that same question asked to an AI agent. It doesn't have a beer to open, it doesn't have a sense of "good enough," and most importantly, it doesn't have an internal sensor that says "stop, you're there." Without that sensor, it does one of two things: stops too early or never stops at all.

## The "done" problem without a definition

When a human works without clear acceptance criteria, two classic scenarios play out.

The first is **under-delivery**. The dev implements the happy path, ignores edge cases, skips error validation, and marks it as complete. Technically it works. In practice, it breaks the first Tuesday of real usage.

The second is **gold-plating**. The dev gets excited. The login that was supposed to be simple gets biometric authentication. The contact form gets a chatbot. The feature becomes a product. Three weeks later, someone asks "why did we spend so much time on this?" and the answer is an awkward silence.

AI agents have exactly the same problems, but amplified.

Agent under-delivery is sneaky. It delivers something that looks complete on the surface. The code compiles, the function names make sense, there are even comments. But when you look closely, you notice the delete function doesn't check permissions, the list endpoint has no pagination, and the email validation accepts "abc@" as valid. The agent stopped because it thought it had fulfilled the request, and technically it did -- in the shallowest way possible.

Agent gold-plating is spectacular. Remember that example from the article about constraints? You ask for a profile page and get a complete identity management system. That's pure gold-plating. The agent doesn't know it should stop after name, email, and bio. Without an explicit signal saying "this is all I need," it keeps adding what it considers relevant. And a model trained on millions of repositories considers a lot of things relevant.

## The definition of done that works

In any well-written RFC, there's a section that solves this problem at the root: **acceptance criteria**.

Don't confuse them with requirements. Requirements describe what to build. Acceptance criteria describe how to know that what was built is correct. It's the difference between "implement login" and "the user can log in with email and password, gets a clear error when the password is wrong, and the session expires after 60 days."

For humans, acceptance criteria serve as a contract between whoever asks and whoever implements. If all criteria pass, the feature is done. No discussion, no subjectivity, no "but I thought it needed more."

For AI agents, they serve as a **stop signal**. The agent knows it's done when it can check each item on the list and confirm it's been addressed. Without that list, it uses its own intuition -- and the intuition of an LLM is "do everything I've ever seen done in similar contexts."

## The difference between vague and precise

Let's take a concrete example. Imagine you're asking an agent to implement user registration for an application.

**Vague criterion:**

```
The user can register and log in.
```

What does the agent deliver with this? It depends on the model's mood that day. Maybe a form with email and password. Maybe a system with OAuth, email verification, password recovery, 2FA, and social login. Both interpretations satisfy "the user can register and log in." The criterion is so broad that anything passes.

**Precise criteria:**

```
Acceptance criteria:
- User can register with email and password
- Password must be at least 8 characters, validated on client and server
- Email must be unique in the system (clear error if already exists)
- After registration, user receives confirmation email within 30 seconds
- User can only log in after clicking the confirmation link
- Login with invalid credentials returns "Incorrect email or password" (without revealing which)
- Session persists for 60 days of inactivity
- Logout invalidates the session immediately
```

The difference is dramatic. The first criterion leaves the agent in the dark. The second turns on all the lights. Each item is verifiable, specific, and testable. The agent knows exactly when it stopped implementing too early (if an item is missing) and when it's going too far (if it's doing something no item asked for).

## The triple-use trick

Here's the part that ties everything together. Read those precise criteria again. Now try to see them from three different angles.

**Angle 1 -- Definition of done in the RFC.** Each item is an acceptance criterion that the engineering team uses to know if the feature is complete. The product manager reads the list, checks each point, signs off. Standard.

**Angle 2 -- Test specification.** Each item is a test case. "Password must be at least 8 characters" becomes `test "rejects password with less than 8 characters"`. "Email must be unique" becomes `test "returns error when email already exists"`. The criteria list is, in practice, your test suite written in natural language.

**Angle 3 -- Prompt instructions.** Each item is a constraint for the agent. "Session persists for 60 days" tells exactly what to configure. "Login with invalid credentials returns a generic message" tells exactly what the error behavior should be. The agent reads this and knows what to do, what not to do, and when to stop.

Three documents. The same text. That's communication efficiency.

I call this the **triple-use pattern**: acceptance criteria written with sufficient precision serve simultaneously as a definition of done, a test specification, and a prompt instruction. You write once, use three times.

## How to write criteria that work in all three contexts

After months of refining this approach, I've found four rules that make all the difference.

**1. Each criterion should be verifiable by someone without context.** If someone who has never seen the project can read the criterion and say "yes, this works" or "no, this doesn't work," the criterion is good. "The user experience should be good" fails this test. "The registration form loads in under 2 seconds" passes.

**2. Use numbers whenever possible.** "The password should be strong" is subjective. "The password must have at least 8 characters, including one uppercase letter and one number" is objective. Agents respond very well to numbers because they eliminate ambiguity. Humans do too, though they tend to complain more about it.

**3. Include error scenarios.** Most acceptance criteria only cover the happy path. This is an invitation for under-delivery, because the agent (and the dev) will focus on what goes right and ignore what goes wrong. "Login with invalid credentials returns a 401 error with a generic message" is just as important as "login with valid credentials creates a session."

**4. Separate behavior from implementation.** The criterion says what the system does, not how it does it. "Session persists for 60 days" is behavior. "Use JWT with 60-day expiration stored in an HttpOnly cookie" is implementation. Acceptance criteria describe the what. Technical constraints (which we covered in the previous article) describe the how.

## Criteria in practice: before and after

Let's see this in a real prompt. Imagine you want an agent to implement a bookmarks system.

**Before -- without acceptance criteria:**

```
Create a bookmarks system for saving links.
The user should be able to add, edit, and remove bookmarks.
Use Phoenix LiveView.
```

What will happen? The agent will implement something. Maybe it'll work, maybe it won't. Maybe it'll have validation, maybe it won't. Maybe it'll handle duplicate URLs, maybe it won't. You'll find out when you test, and then the correction cycle begins.

**After -- with acceptance criteria:**

```
Create a bookmarks system for saving links.

## Acceptance criteria
- User can add a bookmark with URL and title (both required)
- URL is validated for format (must start with http:// or https://)
- Duplicate URLs for the same user return a clear error
- Title has a 200-character limit (silently truncates if longer)
- User can edit the title of an existing bookmark
- User can remove a bookmark with confirmation (soft delete)
- Bookmark list shows title, URL, and creation date
- List is sorted by creation date (most recent first)
- List has pagination with 20 items per page
- User can only see their own bookmarks (never another user's)

## Out of scope
- Tags or categories
- Search or filters
- Import/export
- Link previews (unfurl)
- Sharing
```

With the second version, the agent has a checklist. Each item is a verifiable behavior. When all of them are implemented, it stops. If it starts adding tags or search, it's violating the scope. If it doesn't implement pagination, it's missing a criterion. The boundary is clear in both directions.

## The stop signal agents need

This is the most subtle point in the entire article. Humans have a built-in "good enough" mechanism. We feel when something is done. Sometimes we err on the side of more, sometimes less, but there's an instinct there.

Agents don't have this. They're optimizers without brakes. If the prompt says "create a bookmarks system," they'll optimize for "the best bookmarks system I can generate" -- which includes everything they know about bookmarks. And they know a lot.

Acceptance criteria are the brakes. They're the stop signal the agent doesn't naturally have. They're the difference between an agent that produces exactly what you need and an agent that produces everything it knows.

And the beautiful part: the same brakes work for humans. The same list that tells the agent "stop here" tells the dev "finish here" and tells QA "test this."

## What's coming next

In the next article, we'll talk about **feedback loops** -- the point where prompts go beyond what traditional RFCs offer. RFCs are static documents. Prompts can be dynamic. And when you combine acceptance criteria with iterative feedback, the quality of the result shifts to a whole new level.

---

### Series: RFCs as Prompts for AI-Agent Development

1. [The fundamental connection](/blog/the-rfc-nobody-read-and-the-prompt-nobody-wrote)
2. [Anatomy of a good RFC](/blog/the-anatomy-of-a-good-rfc)
3. [Anatomy of a good system prompt](/blog/the-anatomy-of-a-good-system-prompt)
4. [Explicit constraints -- The power of "don't do this"](/blog/explicit-constraints-the-power-of-dont-do-this)
5. Interfaces and contracts *(coming soon)*
6. **Acceptance criteria -- When the agent knows it's done** *(this article)*
7. Feedback loops *(coming soon)*
8. Shared context *(coming soon)*
9. The unified document *(coming soon)*
10. The future of specification *(coming soon)*

---

Enjoyed this? Want to discuss or disagree? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).
