%{
  title: "Your Skills Are the Moat: 141 Claude Code Sessions, 611 Commits, and What Actually Matters",
  author: "Iago Cavalcante",
  tags: ~w(ai claude coding productivity agents skills agentic-code),
  description: "After 30 days and 141 Claude Code sessions, the data is clear: custom skills are what separate vibe coding from shipping real products. Here's what the numbers say.",
  locale: "en",
  published: true
}
---

Hey folks! A few months back I wrote about [Vibe Coding with Steroids](/blog/vibe-coding-with-steroids-claude-code-agents-superpowers) — the claim was that custom skills, parallel agents, and superpowers turn Claude Code into a productivity machine.

That was theory. Today I've got the receipts.

I ran Claude Code's `/insights` command and the numbers from the last 30 days hit different:

- **141 sessions analyzed**
- **611 commits**
- **96% goal achievement rate**
- **952 TaskUpdate calls, 506 Agent invocations**

That's shipping-focused orchestration at scale. And the one thing doing the heavy lifting in those numbers isn't the model. It's the skills.

## The Agentic Coding Connection

I recently helped review a book called [*Agentic Coding: Claude Code for Developers*](https://www.amazon.com/Agentic-Coding-Claude-Code-Developers/dp/1806022591) — and one of the core ideas stuck with me: **agents aren't magic, they're disciplined systems**. The magic happens when you give them the right context, the right process, and the right boundaries.

That's literally what custom skills do. They're not just prompts — they're distilled expertise that survives between sessions. You teach Claude once, it remembers forever.

Which brings me to the thesis of this post:

> **Your skills are the moat. The model is a commodity.**

Everyone has access to the same Claude. What separates a 10x workflow from a frustrating one is the skills you've built around it.

## 3 Skills That Paid Off

Let me show you what that looks like in practice.

### 1. `write-like-iago` — Voice consistency

I write blog posts, LinkedIn posts, Reddit drafts, and UGC video scripts. Without a skill, every session starts from zero — "write in my voice" means nothing without examples.

```markdown
---
name: write-like-iago
description: Use when creating content for Iago Cavalcante
---

## Tone
- Conversational and warm
- Didactic without being condescending
- Start with "Fala, pessoal!" or "Hey folks!"

## Ground concepts in reality
BAD: "Hot reload improves productivity"
GOOD: "You know when you'd create a skill and had to restart the session?"
```

Result: 20+ articles shipped this quarter, voice stayed consistent across PT-BR and EN.

### 2. `elixir-skills` — The router that saves me from myself

This one is sneaky good. It's a skill that *routes to other skills* before Claude explores the code:

```
Elixir/Phoenix/OTP task → Invoke skill FIRST → Then explore → Then code
```

Why? Because skills tell you *what to look for*. Without them, Claude explores blind and often adds a GenServer when a plain function would do. The router catches that early.

### 3. `lovable-web-development` — Design tokens or bust

```
Red flag: text-white  → Do: text-foreground
Red flag: bg-black    → Do: bg-background
Red flag: hex inline  → Do: CSS variables with HSL
```

Built the entire Respira fintech design — landing page plus 10 mobile screens — with zero hardcoded colors. Future me can reskin the whole thing in 20 minutes.

## The Friction (Keeping It Honest)

The report also called out where I still hit walls:

- **Sed-based renames silently corrupted a class** (`SystemPromptBuilder` → `SystemAgentBuilder`). Lesson: always pair bulk renames with `tsc --noEmit`.
- **Token limits cut off 3+ debugging sessions.** Fix: dump findings to `.claude/scratch/` instead of inline.
- **Pre-push hooks amended formatting into the wrong commit.** Force-push recovery isn't fun.

None of this is the AI's fault. It's missing skills. Every friction point is a skill waiting to be written.

## What I'm Codifying Next

Based on the report, here's what goes into my `~/.claude/skills/` this week:

1. **`/pr-review`** — Fetch Gemini review comments, classify valid/invalid, apply fixes, resolve threads, commit, push. I do this 5+ times a week manually.
2. **`/ota-release`** — Bump version, commit, `eas update --platform ios` then `--platform android` separately (never `--platform all` because web isn't configured).
3. **Pre-commit hook** — Auto-run prettier and `eslint --fix` on edited TS files. Kills the force-push recovery cycle.

Small skills, big leverage.

## How to Start

You don't need 141 sessions worth of data to start building skills. You need one painful, repeated workflow.

1. Notice you're doing the same thing twice → **candidate for a skill**
2. Write a 20-line markdown file in `~/.claude/skills/your-skill/SKILL.md`
3. Add the frontmatter with `name` and `description`
4. Use it three times. Refine. Ship.

The `description` field is the most important part — Claude uses it to decide when to invoke the skill. Be specific about the trigger.

## The Real Insight

After a month of data, here's what I actually believe now:

**Agentic development isn't about the model getting smarter. It's about you getting better at teaching it.**

The 96% goal achievement rate isn't because Claude is magic. It's because every week I'm feeding it a sharper version of my patterns, preferences, and constraints. The skill folder is the compound interest.

Vibe coding with steroids gets you started. Skills are what make it stick.

---

**Got a painful workflow that repeats?** That's your next skill.

Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante) — curious to see what you're codifying.

Happy coding!
