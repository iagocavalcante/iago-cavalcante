%{
  title: "The Anatomy of a Good RFC",
  author: "Iago Cavalcante",
  tags: ~w(ai software-engineering rfcs prompts agents development),
  description: "Every RFC that works has six essential pieces. If you know how to assemble them for humans, you already know how to assemble them for AI agents.",
  locale: "en",
  published: false,
  scheduled_for: ~D[2026-02-19]
}
---

Hey folks! Let me start with a story that sounds trivial but happens every week at some engineering team somewhere.

A team of five devs spent three sprints building a notification system. Push notifications, email, SMS, webhooks -- the full package. On demo day, the product manager looked at the screen and said: "Cool, but we only needed email. And only for password recovery."

Three sprints. Five engineers. A month of work. All because nobody stopped to write down what exactly needed to be built -- and more importantly, **what did NOT need to be built**.

If that team had written an RFC before opening their code editor, they would have discovered in thirty minutes that the scope was ten times smaller than they imagined. But they didn't. And they paid the price.

## The six pieces every good RFC has

In the [previous article](/blog/the-rfc-nobody-read-and-the-prompt-nobody-wrote), I showed that the structure of an RFC is essentially the same as a good prompt. Today we're going to crack that structure open piece by piece and understand **why each one exists** and what goes wrong when you skip it.

Every RFC that actually works -- not just on paper -- has six sections. They're not optional. Each one prevents an entire category of failure.

We'll use the same authentication example from the previous article, but evolved to show how each section connects.

## 1. Problem Statement -- The why before the how

The first section of any RFC should answer a simple question: **why are we doing this?**

Seems obvious, but most technical documents jump straight to the solution. "We'll implement OAuth2 with Google and GitHub." Great. But why? What problem does that solve? Who is being affected? What's the cost of doing nothing?

For our authentication example:

```
## Problem Statement

Currently, anyone with the link can access the admin panel.
There is no user identification, which prevents:

- Auditing who changed configurations
- Personalizing the experience by profile
- GDPR compliance (without knowing who the user is,
  we can't fulfill data deletion requests)

In the last 30 days, we had 3 incidents where configurations
were changed and we couldn't identify who was responsible.
```

**What happens when this section is missing:** the team builds the right thing the wrong way, or the wrong thing the right way. Without understanding the problem, any solution looks valid. And that's how you spend three sprints on a notification system nobody asked for.

**The golden rule:** if you can't explain the problem without mentioning the solution, you don't understand the problem yet.

## 2. Proposed Solution -- The how, separated from the why

Now we're talking. After defining the problem clearly, you propose how to solve it.

The separation between problem and solution seems subtle, but it makes all the difference. When you mix the two, nobody can question the solution without seeming like they're questioning whether the problem exists at all.

```
## Proposed Solution

Implement email and password authentication using phx_gen_auth:

1. Generate the auth module with `mix phx.gen.auth Accounts User users`
2. Configure email confirmation via token (validity: 24h)
3. Add authentication plug to admin panel routes
4. Create login page with email/password form

Technical stack:
- Argon2 for password hashing (already a project dependency)
- Swoosh + Resend for transactional emails
- Cookie-based session with 60-day validity
```

**What happens when this section is vague:** every dev interprets it differently. One uses bcrypt, another uses Argon2. One creates new tables, another reuses existing ones. The merge request ends up as a Frankenstein.

## 3. Constraints -- The fences around the playground

Constraints are the rules of the game. They define the space within which the solution must exist. They can be technical, business-related, time-bound, compliance-driven -- anything that limits your options.

```
## Constraints

- MUST use the existing Accounts structure in the project
  (do not create a new context)
- MUST use Argon2 for password hashing (team standard)
- CANNOT add external authentication dependencies
  (Guardian, Pow, etc.) -- use phx_gen_auth only
- Deploy must be compatible with current Fly.io infrastructure
- Maximum implementation time: 1 sprint (2 weeks)
```

**What happens when this section is missing:** too much freedom. The dev (or the agent) picks the most popular library of the moment, which may not be compatible with the project. Or optimizes for performance when the actual requirement is simplicity.

Constraints aren't limitations -- they're decisions already made that prevent rework.

## 4. Non-Goals -- The most underrated section

This is, by far, **the most important and most ignored section** of any RFC.

Non-goals aren't things you don't want to do. They're things that a reasonable person could assume are in scope, but that you're explicitly excluding. The difference is subtle but crucial.

```
## Non-Goals

- Password recovery (will be addressed next cycle, RFC-005)
- Social login (Google, GitHub) -- evaluation planned for Q3
- Two-factor authentication (2FA)
- Roles/permissions system (RBAC)
- Authentication API for external clients (web only)
- Rate limiting on login attempts (will be handled via Cloudflare)
```

**What happens when this section is missing:** infinite scope. Every RFC reviewer will suggest "but what if we also did X?" And if you don't have an explicit place to say "no, X comes later," the scope grows until it swallows the timeline.

I've seen RFCs where the non-goals section was longer than the proposed solution section. And those were the best RFCs. Because **saying what you WON'T do is just as important as saying what you will**.

## 5. Open Questions -- The honesty section

This is where you admit what you don't know. And that's powerful.

Every project has unknowns. The difference between a good RFC and a bad one is that the good one doesn't pretend to have all the answers.

```
## Open Questions

1. Should we allow multiple simultaneous sessions per user?
   - Initial proposal: yes, with a limit of 5 active sessions
   - Need to validate with product whether this creates a
     security risk

2. What's the behavior when the confirmation token expires?
   - Option A: user must register again
   - Option B: automatic resend of email with new token

3. Do we need structured logging for authentication events
   from day 1, or can we add it later?
```

**What happens when this section is missing:** the questions surface mid-development. And the answer becomes a hallway decision that isn't documented anywhere. Two months later, nobody remembers why it was decided that way.

Open questions aren't weakness. They're technical maturity.

## 6. Acceptance Criteria -- How you know it's done

The last piece is the most pragmatic: how do you know it worked?

Without acceptance criteria, "done" becomes a negotiation. The dev thinks it's finished, QA disagrees, the PM has a different definition, and the stakeholder has a fourth one.

```
## Acceptance Criteria

- [ ] User can register with email and password
- [ ] Confirmation email is sent within 30 seconds
- [ ] User can log in after confirming email
- [ ] User CANNOT access protected routes without logging in
- [ ] Session expires after 60 days of inactivity
- [ ] Login attempt with invalid credentials returns a generic
      message (without revealing whether the email exists)
- [ ] Automated tests cover all flows above
```

**What happens when this section is missing:** the project never ends. There's always one more thing to tweak, one more edge case to cover, one more scenario to test. Acceptance criteria are the finish line.

## This isn't just theory

This six-section model isn't something I invented. It's an industry-validated practice.

Gergely Orosz, at The Pragmatic Engineer, describes a five-step RFC process -- plan before building, document, seek approval, distribute for feedback, and iterate. Uber scaled this process from tens to thousands of engineers. Google uses design docs, and Facebook, Microsoft, and Amazon all have similar processes.

The pattern is the same: **before writing code, write down what the code will do, what it won't do, and how to know if it worked.**

## The anti-pattern: the RFC without non-goals

If I had to pick the single most common RFC failure, it would be missing non-goals. And you know why? Because not writing non-goals feels efficient. "We just need to describe what we're doing, right?"

Wrong. Because without non-goals:

- Reviewers suggest extra features that bloat the scope
- Devs assume adjacent work is part of the task
- AI agents invent functionality "because it makes sense"

Non-goals are the brakes of a project. Without brakes, any car crashes.

## The bridge to the next article

Look at those six sections again:

1. Problem Statement
2. Proposed Solution
3. Constraints
4. Non-Goals
5. Open Questions
6. Acceptance Criteria

Now think: how does each of these translate to an AI agent's system prompt?

The problem statement becomes context. The constraints become rules. The non-goals become explicit exclusions. The acceptance criteria become expected output format. The open questions... well, those become something traditional RFCs don't have -- but prompts need.

Next week, we'll make that exact translation. Piece by piece.

---

**Series: RFCs as Prompts for AI-Agent Development**

1. [The RFC Nobody Read and the Prompt Nobody Wrote](/blog/the-rfc-nobody-read-and-the-prompt-nobody-wrote) - The fundamental connection
2. **The Anatomy of a Good RFC** - The structural elements that work *(this article)*
3. **Anatomy of a good system prompt** - The RFC's mirror
4. **Explicit constraints** - The power of "don't do this"
5. **Interfaces and contracts** - How agents respect boundaries
6. **Acceptance criteria** - When the agent knows it's done
7. **Feedback loops** - Where prompts go beyond RFCs
8. **Shared context** - What RFCs assume and agents need to hear
9. **The unified document** - Writing for humans and agents at the same time
10. **The future of specification** - When the RFC is the code

---

Enjoyed this? Think there's an RFC section I missed? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).
