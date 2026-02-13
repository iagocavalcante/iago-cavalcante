%{
  title: "The Anatomy of a Good System Prompt",
  author: "Iago Cavalcante",
  tags: ~w(ai software-engineering rfcs prompts agents development),
  description: "Every section of an RFC has an exact mirror in the world of prompts. Once you see the mapping, writing prompts becomes second nature.",
  locale: "en",
  published: false,
  scheduled_for: ~D[2026-02-26]
}
---

Hey folks! Last week we dissected the RFC. Today we hold up a mirror.

If the previous article showed *why* an RFC's structure works, this one shows *where* each piece fits in the world of system prompts. And once you see the mapping, something shifts: writing prompts stops being guesswork and becomes engineering.

## The mirror: RFC vs. system prompt

Let's get straight to it. Every classic section of an RFC has a direct equivalent in a system prompt:

| RFC Element | Prompt Equivalent |
|---|---|
| Problem Statement | Context / Role definition |
| Proposed Solution | Task description |
| Constraints | Rules / Boundaries |
| Non-Goals | Explicit exclusions ("Do NOT...") |
| Open Questions | Clarification requests |
| Acceptance Criteria | Output format / Success criteria |

Seems too simple? It does. But most prompts out there ignore at least half of these sections. And that's exactly where things go wrong.

Let's walk through each row of that table with concrete examples.

## Problem Statement -> Context and role

In the RFC, the problem statement answers: "why are we doing this?" In the prompt, context does the same thing. It anchors the agent in a specific reality.

Without context, the agent operates in a vacuum. With context, it knows *who* it is, *where* it is, and *why* it was called.

```
# Without context (problem statement)
"Process these notifications."

# With context
"You are the notification service for an e-commerce platform
with 50,000 active users. We need to ensure that each purchase
event generates the correct notifications without duplicates."
```

The difference is the same as between an RFC that opens with "We need notifications" and one that opens by explaining event volume, current duplication issues, and the impact on support tickets.

## Proposed Solution -> Task description

The proposed solution in an RFC says *what* will be built. In the prompt, the task description does the same: it tells the agent exactly what it needs to do.

```
# Vague
"Send the right notifications."

# Precise
"For each purchase event received, determine the applicable
notification channels (email, push, SMS) based on the user's
preferences, generate message content using the corresponding
template, and enqueue for delivery."
```

In the RFC, the proposed solution has action verbs and describes flows. In the prompt, same thing. Clarity here is what separates a productive agent from a lost one.

## Constraints -> Rules and boundaries

This is perhaps the most neglected section -- and the most powerful. In the RFC, constraints say: "build within these walls." In the prompt, rules do the same.

```
# Without constraints
"Send notification via email."

# With constraints
"Use only the SendGrid provider already configured in the project.
Do not introduce new email services.
Rate limit: maximum 100 emails per minute.
All messages must follow existing templates in /templates."
```

This is where you prevent the agent from making decisions on its own. Without constraints, it picks the path that seems most logical to it -- which is rarely the most logical for your project.

## Non-Goals -> Explicit exclusions

If constraints say what to do *within*, non-goals say what stays *outside*. In prompt world, this translates to explicit exclusions -- the "Do NOT" statements.

```
"Do NOT implement:
- Notification preference system (already exists)
- Automatic retry on provider failures (to be handled in phase 2)
- Email open analytics
- Real-time notifications via WebSocket"
```

Seems obvious? To an experienced human on the project, maybe. To an agent, not at all. Without these exclusions, a capable model will look at the notification domain and *naturally* think about retry, analytics, real-time. It's trying to be thorough. Your job is to tell it where thoroughness ends.

## Open Questions -> Clarification requests

In the RFC, open questions are points the author hasn't resolved yet and wants to discuss with the team. In the prompt, this translates to instructing the agent to ask before deciding.

```
"If the user has no channel preference configured,
ASK which channel to use instead of assuming a default.
If the template for the event type doesn't exist,
STOP and report the error instead of generating generic content."
```

This section transforms the agent from a blind executor into a collaborator. Instead of filling gaps with assumptions (which is the model's natural instinct), it signals uncertainty. Exactly like a good engineer would when reading an RFC with open items.

## Acceptance Criteria -> Output format and success criteria

In the RFC, acceptance criteria define "how we know it worked." In the prompt, they define the expected format and quality of the output.

```
"Expected output for each processed notification:
- status: 'queued' | 'skipped' | 'error'
- channel: selected channel
- reason: explanation if skipped or error
- timestamp: ISO 8601

Success = all notifications processed without unhandled
exceptions, with structured logging of each decision."
```

Without acceptance criteria, how do you know the agent did a good job? You don't. You go by gut feeling. And gut feeling doesn't scale.

## In practice: from RFC to prompt

Enough theory. Let's take a fictional notification service RFC and transform it into a system prompt. Side by side.

### The RFC

```
TITLE: Notification Service for Purchase Events

PROBLEM:
Currently, purchase notifications are fired inline in the
orders controller. This causes timeouts during traffic spikes
and there is no duplicate control.

PROPOSED SOLUTION:
Create an asynchronous service that consumes purchase events
from a queue, determines applicable channels per user, and
enqueues messages for delivery via existing providers.

CONSTRAINTS:
- Use the already-provisioned SQS queue
- Providers: SendGrid (email), Firebase (push)
- Do not create new templates; use existing ones
- Maximum latency: 30s between event and enqueue

NON-GOALS:
- Marketing notifications
- Preferences system (already exists, just consume it)
- Provider failure retry (phase 2)

OPEN QUESTIONS:
- Should we aggregate notifications for multiple items
  in the same order?
- What is the fallback if the primary provider goes down?

ACCEPTANCE CRITERIA:
- Purchase event generates notification in < 30s
- Zero duplicates per event
- Structured log of each decision (channel, status, reason)
```

### The system prompt

```
ROLE:
You are the notification service for an e-commerce platform.
Your function is to process purchase events and ensure each
event generates the correct notifications without duplicates.

TASK:
For each purchase event received:
1. Look up the user's channel preferences
2. Determine applicable channels (email via SendGrid,
   push via Firebase)
3. Select the existing template for the event type
4. Enqueue the message for delivery

RULES:
- Use ONLY SendGrid for email and Firebase for push
- Use ONLY existing templates; do not generate freeform content
- Maximum latency between receiving event and enqueuing: 30s
- Ensure idempotency: same event processed twice must not
  generate duplicate notification

DO NOT:
- Do not process marketing events
- Do not modify user preferences; only read them
- Do not implement provider failure retry
- Do not create new templates

WHEN IN DOUBT:
- If an order has multiple items and you're unsure whether
  to aggregate, ASK before processing
- If the primary provider is unavailable, REPORT the error
  instead of trying alternatives

OUTPUT FORMAT:
For each notification, return:
{
  "event_id": "string",
  "status": "queued | skipped | error",
  "channel": "email | push",
  "reason": "string (if skipped or error)",
  "timestamp": "ISO 8601"
}
```

Look at both side by side. Every section of the RFC mapped directly to a section of the prompt. The problem became the role. The solution became the task. The constraints became rules. The non-goals became "DO NOT." The open questions became "WHEN IN DOUBT." The acceptance criteria became the output format.

Not a coincidence. It's the same thinking structure, applied to a different audience.

## Vague vs. structured: what changes in practice

To make the contrast clear, here's what happens when you use a vague prompt versus an RFC-structured prompt.

**Vague prompt:**
```
"Create a notification service for my e-commerce."
```

The agent will likely: pick its own providers, invent a template system, implement retry logic, add analytics, build a preferences dashboard, and maybe even throw in an A/B testing framework for messages. All of that without you asking. Lots of work, little value, and hours of cleanup ahead.

**RFC-structured prompt:**

What we wrote above. The agent does exactly what was asked, within the boundaries that were defined, and flags anything it can't resolve on its own.

Gergely Orosz, in The Pragmatic Engineer, makes an observation that fits perfectly here: how information flows shapes team culture. The same applies to agents. The structure of your prompt shapes the agent's behavior.

## Writing as a quality gate

One last thought. In mature engineering teams, the RFC goes through review before it becomes code. Someone reads it, questions it, points out gaps. It's a quality gate.

System prompts deserve the same treatment. If a prompt is going to guide the behavior of an agent that interacts with your production system, it should go through a review as rigorous as a pull request.

Read the prompt out loud. Ask yourself: "if a junior dev read this, would they know what to do?" If the answer is no, the agent won't know either. Revise. Get feedback. Treat the prompt as an engineering artifact, not throwaway text.

## What's next

Now that you see the mirror, the next step is mastering one of the most underrated sections: explicit constraints. In Article 4, we'll explore why "Do NOT" is just as powerful as "Do" -- and how well-written constraints prevent 80% of the problems with agents.

---

### Series navigation

1. [The RFC Nobody Read and the Prompt Nobody Wrote](/blog/the-rfc-nobody-read-and-the-prompt-nobody-wrote) - The fundamental connection
2. **Anatomy of a good RFC** - The structural elements that work
3. **This article** - The RFC's mirror in prompt world
4. **Explicit constraints** - The power of "don't do this"
5. **Interfaces and contracts** - How agents respect boundaries
6. **Acceptance criteria** - When the agent knows it's done
7. **Feedback loops** - Where prompts go beyond RFCs
8. **Shared context** - What RFCs assume and agents need to hear
9. **The unified document** - Writing for humans and agents at the same time
10. **The future of specification** - When the RFC is the code

---

Liked the mapping? Want to discuss how to apply this on your team? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).
