%{
  title: "The RFC Nobody Read and the Prompt Nobody Wrote",
  author: "Iago Cavalcante",
  tags: ~w(ai software-engineering rfcs prompts agents development),
  description: "The same discipline that makes an RFC work for human engineers is what makes a prompt work for AI agents. Most developers already have this skill - they just haven't realized it yet.",
  locale: "en",
  published: true
}
---

Hey folks! Let me start with a scene every dev has lived through.

Friday, 4pm. You open Jira and there it is, a fresh ticket: **"Add authentication to the system."** That's it. No context, no constraints, no acceptance criteria. Nothing.

If you have some experience, you know what comes next: half an hour of questions on Slack. "Authentication how? OAuth? JWT? Magic link? Do we need 2FA? Which providers? Is there federation? Does the frontend already have a login screen?" Fifteen questions just to start working.

Now imagine that instead of you, an AI agent gets that ticket. What happens?

It doesn't ask. It builds. And it builds the wrong thing.

Without constraints, the agent decides for you. It implements OAuth with Google, creates session tables that conflict with your existing schema, adds bcrypt where you use Argon2, and throws in a permissions system nobody asked for. Three hours of work down the drain.

It's not the agent's fault. It's the ticket's fault.

## The vague ticket is the universal enemy

Here's the point few people connect: **the same problem that makes a human dev stall is what makes an AI agent hallucinate.** Lack of context, lack of boundaries, lack of a clear definition of what "done" means.

You know what has solved this for decades? An RFC.

I'm not necessarily talking about formal IETF RFCs, those documents that defined TCP and HTTP. I'm talking about the concept: a document that describes a problem, proposes a solution, makes explicit what is NOT in scope, and defines how to know if it worked.

Engineering teams worldwide use some variation of this. Design doc, ADR, tech spec — the name changes, the function is the same. And that function is more relevant today than ever.

## When the RFC meets the prompt

Here's the insight that changed how I work with AI agents.

Take that vague ticket — "Add authentication" — and turn it into a mini-RFC:

**Problem:** Users access the system without identification. We need login to personalize the experience and protect sensitive data.

**Proposed solution:** Email and password authentication using `phx_gen_auth`, with email confirmation via token.

**Constraints:**
- Use the existing accounts structure in the project
- Passwords with Argon2 (project standard)
- No OAuth for now
- No permissions/roles system in this phase

**Out of scope:**
- Password recovery (next cycle)
- Social login (Google, GitHub)
- 2FA

**Acceptance criteria:**
- User can register with email and password
- User receives a confirmation email
- User can log in after confirming email
- Session expires after 60 days of inactivity

Now read that again. But this time, instead of thinking of it as a document for an engineering team, think of it as a prompt for an AI agent.

See it?

**It's the same thing.**

The problem becomes context. The constraints become rules. The out-of-scope becomes explicit exclusions. The acceptance criteria become expected output format. The structure that works for communicating intent between humans is exactly the one that works for communicating intent to machines.

## An RFC is a prompt for humans. A prompt is an RFC for agents.

That's the core thesis of this article series. And it has an implication few people realize: **most developers already know how to write good prompts — they've just never connected the two things.**

If you've ever written a decent design doc, you know how to be specific about constraints. If you've ever defined acceptance criteria in a user story, you know how to tell an agent when to stop. If you've ever written a "non-goals" section in an RFC, you know how to prevent an agent from inventing features nobody asked for.

The skill exists. What's missing is the bridge.

## The anti-pattern: the prompt-ticket

You know what most people do when working with an AI agent? They write the digital equivalent of that vague Jira ticket:

```
"Create an authentication system for my Phoenix app"
```

And then complain the result isn't what they wanted. Worse — they get stuck in an incremental correction loop:

```
"No, use Argon2 instead of bcrypt"
"Oh, and no need for OAuth"
"Wait, remove the roles system"
"The schema conflicted, fix that"
```

Each correction is a retroactive mini-RFC. Each "no, do it differently" is a constraint that should have been in the original prompt. You end up spending more time correcting the agent than you would have spent writing a good prompt upfront.

It's like that dev who never reads the RFC and keeps asking questions on Slack. It works — but it's expensive.

## The reverse path works too

Here's an insight I didn't expect: writing good prompts made me write better RFCs.

When you need to be explicit enough for a machine to understand, you discover every ambiguity that a human would fill with assumptions. And assumptions are bugs in disguise.

That sentence that seems clear to you — "use the standard authentication" — an agent doesn't know what "standard" means. And you know what? There's a good chance that junior dev who joined last week doesn't know either.

The discipline of writing for agents improves your writing for humans.

## What's coming next

This is the first article in a series of ten. In the upcoming posts, we'll dig deeper into each element of this bridge between RFCs and prompts:

1. **This article** - The fundamental connection
2. **Anatomy of a good RFC** - The structural elements that work
3. **Anatomy of a good system prompt** - The RFC's mirror
4. **Explicit constraints** - The power of "don't do this"
5. **Interfaces and contracts** - How agents respect boundaries
6. **Acceptance criteria** - When the agent knows it's done
7. **Feedback loops** - Where prompts go beyond RFCs
8. **Shared context** - What RFCs assume and agents need to hear
9. **The unified document** - Writing for humans and agents at the same time
10. **The future of specification** - When the RFC is the code

Each article follows the same pattern: an RFC principle, why it works for humans, the prompt equivalent, a practical example, and the anti-pattern to avoid.

---

If you already write good design docs, you're closer to mastering AI agents than you think. And if you've never written an RFC in your life, this series will teach you a skill that works in both worlds.

Next week, we'll dissect the anatomy of a good RFC — piece by piece.

Got questions or want to discuss? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).
