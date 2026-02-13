%{
  title: "Where the Prompt Goes Beyond the RFC: Feedback Loops",
  author: "Iago Cavalcante",
  tags: ~w(ai software-engineering rfcs prompts agents development),
  description: "RFCs are static documents. Prompts are interactive conversations. When you combine the discipline of one with the flexibility of the other, that's where the magic happens.",
  locale: "en",
  published: false,
  scheduled_for: ~D[2026-03-26]
}
---

Hey folks! Until now, everything mapped perfectly. RFCs to prompts, one to one. But today we break the symmetry.

Across the previous six articles, I showed how RFC discipline translates directly into the world of prompts: structure, constraints, interfaces, acceptance criteria. Every section of the RFC found its mirror in the system prompt. It was neat, it was useful, and it still holds.

But if the story stopped there, a prompt would just be an RFC in different clothes. And it's not. Starting with this article, the conversation changes. Because prompts do something RFCs simply can't: **they talk back.**

## The document that doesn't answer

Let's be fair to the RFC. It's a brilliant engineering artifact. It organizes thinking, aligns teams, documents decisions. Decades of practice have proven it works.

But it's static.

Once an RFC is approved, it becomes reference material. You don't "talk" to an RFC. You don't say "hey, that part about authentication, switch it to OAuth2 instead of JWT." You write a new RFC. Or an amendment. Or open a Slack thread that nobody will read two months from now.

The feedback cycle of an RFC is slow by design. Writing, review, approval, implementation, retrospective. Each stage can take days or weeks. And that's fine -- for long-term architectural decisions, that cadence makes sense. You want deliberation, not speed.

But when the "reader" of your document is an AI agent that executes in seconds, that slow cycle becomes a bottleneck. You wrote the perfect prompt (with all the RFC discipline we've discussed), sent it to the agent, got the result... and realized you missed a detail. That a premise was wrong. That the context changed between writing and execution.

What do you do? With an RFC, you go back to the beginning. With a prompt, you **continue the conversation.**

## The superpower RFCs don't have

Interactivity is the superpower of prompts. And it manifests in three feedback patterns I consistently see in the best agent workflows.

### Pattern 1: Incremental context

You don't need to know everything before you start. You can begin with what you know and add information as the agent works.

```
[Initial prompt]
Create a payment processing module.
Use Stripe as the provider. Support credit cards.

[After seeing Phase 1 result]
Now add support for PIX (Brazilian instant payments).
The endpoint is /api/pix on our internal gateway.
Use the same error handling pattern you created
for credit cards.

[After seeing Phase 2 result]
The compliance team just confirmed: we need an
idempotency key on all transactions. Add this to
the functions you already created, using UUID v4.
```

In an RFC, all of this information would need to be there from the start -- or you'd have to write a formal amendment. In a prompt, you add context as it becomes available. The agent absorbs and adapts.

### Pattern 2: Multi-turn memory

Each agent response carries the context of previous interactions. This allows you to build complexity incrementally, without repeating everything in each message.

```
[Turn 1] "Create the user schema with name and email."
[Turn 2] "Add format validation on email."
[Turn 3] "Now create the registration changeset with
          password confirmation."
[Turn 4] "Refactor: extract the email validations
          into a shared module."
```

Each turn builds on the previous one. The agent doesn't forget what it did in turn 1 when it reaches turn 4. It has the accumulated context. This is something a static document simply doesn't offer -- you can't "build upon" an RFC iteratively in real time.

### Pattern 3: Correction without restart

Perhaps the most valuable pattern. You can correct the agent's course without discarding everything and starting from scratch.

```
[Prompt] "Create a REST API for task management."
[Result] The agent built it with API key authentication.

[Correction] "Authentication should be via JWT, not API
key. Keep everything else, just swap the auth mechanism."
```

The agent keeps 90% of the work and adjusts the 10% that needed changing. In a pure RFC-based flow, the correction would mean: noting the problem, updating the document, re-submitting for review, and only then implementing. With the prompt, the correction is instant and surgical.

## Two teams, two worlds

To make the difference concrete, imagine two teams working on the same problem: building a product recommendation service.

**Team A -- the prompt as a frozen RFC:**

Team A writes a detailed, complete prompt. RFC structure, constraints, acceptance criteria, everything in place. Sends it to the agent. Accepts the result. If they don't like it, they rewrite the entire prompt and try again.

The result is usually good on the first try -- after all, the prompt was well written. But when it needs adjustment, the cost is high. Each iteration is a full write-execute-evaluate cycle. In a workday, Team A manages maybe 3 or 4 significant iterations.

**Team B -- the prompt with feedback checkpoints:**

Team B writes the same initial prompt with the same discipline. But they divide execution into phases with review points.

```
Phase 1: Define the data types and schema for the
recommendation service.
-> [CHECKPOINT] Deliver the schema. I'll review before
   you proceed.

Phase 2: Implement the basic scoring logic.
-> [CHECKPOINT] Deliver the scoring function. I'll
   validate the weights.

Phase 3: Create the API endpoints.
-> [CHECKPOINT] Deliver the endpoints. I'll test
   before integration.

Phase 4: Add caching and optimizations.
-> [CHECKPOINT] Deliver the final version.
```

Between each checkpoint, Team B reviews, adjusts, adds context. "The schema looks good, but add a category field." "The scoring function needs to account for seasonality -- here's the data." "The endpoints are great, but change the response format to this pattern."

In a workday, Team B makes dozens of micro-iterations. The final result is more refined, more aligned with what the team actually needs, and with less rework.

The difference isn't that Team B writes better prompts. It's that Team B **treats the prompt as a conversation**, not as a delivered document.

## The anti-pattern: "prompt and pray"

If you recognized Team A, don't feel bad. Most of us start there. I call it **"prompt and pray"** -- writing the prompt, sending it to the agent, and hoping the result is good.

It's the equivalent of writing an RFC, distributing it to the team, and never asking if anyone read it. Or if they agreed. Or if the implementation followed what was written.

"Prompt and pray" has an illusion of efficiency. It seems fast because you only write once. But the time you save on writing, you spend double on evaluation and rework. When the result doesn't match, you discard everything and try again from zero. It's like deploying without tests -- it might work, but when it doesn't, the cost is brutal.

## Template: feedback checkpoints in agent workflows

If you want to move past "prompt and pray" and adopt feedback loops, here's a template that works well in practice:

```
## Context
[Problem description, agent role, constraints
-- all the RFC discipline we've already discussed]

## Phased execution

### Phase 1: [Descriptive name]
Deliverables: [What the agent should produce]
Format: [How it should deliver]
-> STOP here and wait for my review before continuing.

### Phase 2: [Descriptive name]
Prerequisite: Phase 1 approval
Deliverables: [What the agent should produce]
Format: [How it should deliver]
-> STOP here and wait for my review before continuing.

### Phase 3: [Descriptive name]
Prerequisite: Phase 2 approval
Deliverables: [What the agent should produce]
Format: [How it should deliver]

## Feedback rules
- If I request a change, apply ONLY the requested change.
  Do not refactor or "improve" other parts.
- If anything in my feedback is ambiguous, ASK before
  implementing.
- Maintain context from all previous phases.
```

The secret is in the stop instructions. When you tell the agent "STOP here and wait for my review," you create a natural feedback point. The agent delivers a piece, you evaluate, adjust, and only then it continues. It's like a code review in real time, but with cycles measured in minutes instead of hours.

## The central insight

The best way to work with agents isn't choosing between RFC discipline and feedback loops. It's combining both.

RFC discipline gives you the initial structure: clear context, explicit constraints, defined acceptance criteria. Without it, your feedback loops are chaotic -- you end up correcting problems that good constraints would have prevented.

Feedback loops give you the flexibility that RFCs don't have: the ability to adapt, correct, and refine in real time. Without them, you're stuck in "prompt and pray," hoping to get everything right on the first try.

**RFC without feedback = rigidity.** Good results on the first attempt, high cost when changes are needed.

**Feedback without RFC = chaos.** Lots of iteration, little direction, unpredictable results.

**RFC + feedback = real prompt engineering.** Structure that guides, flexibility that refines.

## What's coming next

If feedback loops are about the conversation between you and the agent, the next article is about what happens when that conversation needs context that goes beyond the prompt. We'll talk about **shared context** -- the information that RFCs assume everyone knows and that agents need to hear explicitly.

---

### Series: RFCs as Prompts for AI-Agent Development

1. [The fundamental connection](/blog/the-rfc-nobody-read-and-the-prompt-nobody-wrote)
2. [Anatomy of a good RFC](/blog/the-anatomy-of-a-good-rfc)
3. [Anatomy of a good system prompt](/blog/the-anatomy-of-a-good-system-prompt)
4. [Explicit constraints — The power of "don't do this"](/blog/explicit-constraints-the-power-of-dont-do-this)
5. Interfaces and contracts *(coming soon)*
6. Acceptance criteria *(coming soon)*
7. **Feedback loops** *(this article)*
8. Shared context *(coming soon)*
9. The unified document *(coming soon)*
10. The future of specification *(coming soon)*

---

Enjoyed this? Want to discuss how to use feedback loops in your workflows? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).
