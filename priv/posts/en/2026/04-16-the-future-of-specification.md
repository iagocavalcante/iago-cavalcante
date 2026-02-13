%{
  title: "The Future of Specification: When the RFC Is the Code",
  author: "Iago Cavalcante",
  tags: ~w(ai software-engineering rfcs prompts agents development),
  description: "The line between specification and implementation is disappearing. The developer who writes the best specification will ship faster than the one who types the fastest code.",
  locale: "en",
  published: false,
  scheduled_for: ~D[2026-04-16]
}
---

Hey folks! Ten weeks. One idea. Let's close the loop.

Throughout this series, I've argued a simple thesis: the same discipline that makes an RFC work for human engineers is what makes a prompt work for AI agents. We covered structure, constraints, interfaces, acceptance criteria, feedback loops, shared context, and the unified document. Each article built on the previous one, showing that writing for machines and writing for people is, at its core, the same skill.

But this series wouldn't be complete if we only looked backward. Today I want to look forward. Because if RFCs and prompts are the same discipline, what happens when agents get good enough that the specification *is* the implementation?

## The four stages of specification

Think with me about how the relationship between specifier and implementer has evolved.

**Stage 1: The human specifies, the human builds.** This is the world we've known for decades. Someone writes an RFC, design doc, or tech spec. Someone else (or the same someone) reads it, interprets it, and writes the code. The document is the reference. The code is the deliverable. Two distinct artifacts, connected by human interpretation.

**Stage 2: The human specifies, the agent builds.** This is the world we explored throughout the series. You write the prompt with RFC discipline -- context, constraints, acceptance criteria -- and the agent generates the code. Still two artifacts. But the translation between them got faster. Minutes instead of days.

**Stage 3: The human specifies, the specification instructs directly.** Here the nature of the thing changes. The specification is no longer a document that someone reads and then implements. It's the build instruction itself. The agent doesn't "interpret" the RFC -- it executes it. The document and the code begin to merge.

**Stage 4: Specification is implementation.** The end state. A sufficiently precise description of what you want *is* the executable artifact. There's no longer a step called "now turn this into code." The "this" already is code. Or better: the distinction between specification and code has stopped making sense.

## Where we are now

We're between stages 2 and 3. And the transition is happening fast.

If you've used an AI agent to write code in the last six months, you've felt it. The gap between "describe what I want" and "have something working" is shrinking. It hasn't disappeared -- you still need to review, adjust, correct. But the distance has measurably decreased.

Two years ago, asking an agent to "create an authentication system with email and password, token confirmation, 60-day sessions" resulted in generic code that needed hours of adjustment. Today, with the right constraints (the same ones we discussed in the articles about constraints and interfaces), the result is usable on the first try. Not perfect. But usable.

And every month, the amount of adjustment needed decreases.

## The skill that matters is shifting

This transition has a profound implication for anyone who builds software.

When the translation from specification to code was manual, the most valued skill was the translation itself. Knowing the language. Mastering the frameworks. Understanding design patterns. Typing fast. Debugging fast. Implementation speed was the differentiator.

When the translation is automated, the most valued skill changes. It becomes the quality of the specification.

Think about it this way: if two developers have access to the same agent, what differentiates their results? Not typing speed. Not syntax knowledge. It's the clarity with which each one describes what they want to build. The precision of the constraints. The completeness of the acceptance criteria. It's, at its core, everything we discussed in this series.

**The developer who writes the best specification will ship faster than the one who types the fastest code.**

Read that sentence again. It sounds provocative, but it's a logical consequence of what's already happening.

## Liberation, not threat

I know what you might be thinking. "If agents are going to write all the code, why do we need developers?"

The answer is the same as always: someone needs to decide *what* to build and *why*. And that part has become more important, not less.

When you spend 80% of your day translating an idea into syntax, you have 20% left to think about the idea itself. When an agent handles the translation, that 80% is freed up for architecture. For design. For understanding the user's problem. For asking the right questions before you start building.

This isn't a threat. It's a liberation.

Less time fighting compilers. Less time debugging type errors. Less time writing boilerplate. More time thinking about what actually matters: the problem that needs solving and the best way to solve it.

The most effective developers I know already work this way. They spend more time at the whiteboard than in the editor. More time defining the problem than writing the solution. And when they finally sit down to code, the code comes quickly because the specification is already clear in their heads. The agent just accelerates that.

## What changes in practice

If specification is becoming the primary artifact, a few things change in day-to-day work.

**Code review becomes spec review.** If the agent generates code from a specification, reviewing the code without reviewing the spec is like reviewing the result without reviewing the premise. The most valuable code review will be the one that questions the specification: "Why this constraint? Does this scope make sense? Are we missing an error scenario?"

**Documentation becomes code.** If the specification is executable, documentation is no longer a separate artifact that gets out of date. It *is* the implementation. Update the spec, update the system. This solves one of software engineering's oldest problems: documentation that lies.

**Onboarding accelerates.** If the system is described by its specification, a new team member doesn't need to read thousands of lines of code to understand what the system does. Read the spec. The spec is the truth.

**Debugging changes nature.** When something breaks, the question shifts from "which line of code has the bug?" to "which part of the specification is incorrect or incomplete?" The bug is in the intention, not the translation.

## Looking back: what we built

Let's recap the entire journey.

In article 1, we established the bridge: RFCs and prompts are the same discipline of communicating intent. In article 2, we dissected the anatomy of a good RFC and saw that each section serves a purpose. In article 3, we mirrored it: the anatomy of a good system prompt follows the same structure.

In article 4, we dove into explicit constraints -- the power of saying "don't do this" is as strong for agents as it is for humans. In article 5, we talked about interfaces and contracts, the glue that keeps composed systems working. In article 6, we defined acceptance criteria as the stop signal agents need.

In article 7, we broke the symmetry: prompts go beyond RFCs because they talk back. Feedback loops are the superpower. In article 8, we tackled shared context -- what humans assume implicitly and agents need to hear explicitly. And in article 9, we brought it all together: the unified document that serves humans and agents at the same time.

Ten articles. One thesis. The bridge is built.

## What comes after the series

This series is becoming a book.

A bilingual book, expanded, with deeper practical examples and an appendix of ready-to-use templates. The concepts I introduced in 1500 words per article will get room to breathe: more scenarios, more edge cases, more nuance.

Keep an eye on my channels for launch updates.

## Start now

If this series convinced you of one thing, I hope it's this: **write your specifications as if an agent will read them. Because soon, one will.**

Not tomorrow. Not "in the future." Now.

Next time you open your editor to write a prompt, apply what we discussed. Clear context. Explicit constraints. Verifiable acceptance criteria. Defined interfaces. Feedback checkpoints. Shared context exposed.

Not because it's fun (though it is). But because this is the skill that will separate those who ship from those who just type. The discipline of specification is the discipline of thought. And thinking clearly never goes out of style.

Thank you for sticking with me through these ten weeks. The conversation doesn't end here -- it changes format. See you in the book.

---

### Series: RFCs as Prompts for AI-Agent Development

1. [The fundamental connection](/blog/the-rfc-nobody-read-and-the-prompt-nobody-wrote)
2. [Anatomy of a good RFC](/blog/the-anatomy-of-a-good-rfc)
3. [Anatomy of a good system prompt](/blog/the-anatomy-of-a-good-system-prompt)
4. [Explicit constraints -- The power of "don't do this"](/blog/explicit-constraints-the-power-of-dont-do-this)
5. [Interfaces and contracts](/blog/interfaces-and-contracts)
6. [Acceptance criteria](/blog/acceptance-criteria)
7. [Feedback loops](/blog/where-the-prompt-goes-beyond-the-rfc)
8. Shared context *(coming soon)*
9. The unified document *(coming soon)*
10. **The future of specification** *(this article)*

---

Enjoyed the series? Want to continue the conversation? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).
