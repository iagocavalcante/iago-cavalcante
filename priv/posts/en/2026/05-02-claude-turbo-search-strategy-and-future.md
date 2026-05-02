%{
  title: "Claude Turbo Search: The Strategy to Save 60% of Tokens (and Where We're Taking It Next)",
  author: "Iago Cavalcante",
  tags: ~w(ai claude coding productivity agents tokens search semantic-search),
  description: "Why I built Claude Turbo Search, the strategy of searching before reading, and the plan to port it to Codex, Antigravity, and Cursor.",
  locale: "en",
  published: false
}
---

Hey folks! If you've been using Claude Code on a real codebase, you already know the pain: every time you open a new session, the agent starts "exploring." It reads files. Then more files. Then the README. Then more files just to be sure. And by the time it actually starts working on your task, you've already burned a third of your context window.

I got tired of paying that tax. So I built [Claude Turbo Search](https://github.com/iagocavalcante/claude-turbo-search).

This post is about the strategy behind it — and where I want to take it next (spoiler: Codex, Antigravity, Cursor).

## The Real Problem Isn't the Model

It's tempting to blame the model. "Claude reads too much." "Cursor wastes tokens." "Codex re-reads files it already saw."

Sure. But the actual bottleneck is upstream: **agentic coding tools default to reading files instead of searching them**.

When I ask "where is authentication handled in this project?", the lazy answer is to read 8 files until you spot it. The smart answer is to grep for `auth` first, narrow the candidates, then read only what's relevant.

Humans do this naturally. Agents, by default, don't. They read.

That's the gap Turbo Search closes.

## The Strategy: Search Before You Read

Three primitives, one philosophy:

1. **Fast file suggestions** — ripgrep + fzf for instant autocomplete. No LLM needed.
2. **Semantic search over docs** — QMD finds files by meaning, not just keywords. The agent searches before reading.
3. **Persistent memory** — sessions don't start from zero. What you learned last week is still there this week.

The skill `/qmd` literally teaches Claude one rule: **search the index, then read only the matches**. That's it. That's the whole trick.

Sounds dumb. The savings are not. On real projects we've seen 60–80% token reductions on exploration tasks. Not because the model got smarter — because the agent stopped re-reading the codebase like it was the first time.

## Why This Compounds

The other piece is memory. Every session, you can run `/remember` and the agent saves what it learned — files touched, decisions made, gotchas discovered. Next session, that context loads automatically.

Sounds simple. The effect is wild: after a few weeks of work, the agent knows your project better than a new contractor would after a month. And it does it without re-reading anything.

Combine that with `/turbo-index` (which sets up ripgrep, fzf, QMD, and cartographer in one shot) and `/token-stats` (so you can actually *see* the savings), and the loop closes.

You're not just saving tokens. You're building a system where context **compounds** instead of resetting every session.

## Where This Is Going Next

Here's the thing: this strategy isn't Claude-specific.

Codex has the same problem. Antigravity has the same problem. Cursor has the same problem. Every agentic coding tool burns tokens re-reading files it could have searched.

So the next chapters of Turbo Search are about portability:

### 1. Port to Codex

OpenAI's Codex agent runs in a different harness, but the bottleneck is identical. The plan is to ship Codex-native equivalents of `/turbo-index`, `/qmd`, and `/remember` — same primitives, different invocation surface. The QMD index is already a portable artifact, so most of the work is in the skill/plugin layer.

### 2. Port to Antigravity

Google's Antigravity is interesting because the agent loop is more autonomous — which means token waste compounds even faster. A search-first discipline saves more there, not less. I want Turbo Search to be the default install on every Antigravity project.

### 3. Port to Cursor

Cursor is the trickiest one because it's an IDE, not a CLI. But Cursor agents have the same exploration problem, and the IDE actually gives us a better surface for fast file suggestions (the editor already knows your buffer state). The plan is a Cursor extension that wraps the same primitives.

## The Bigger Bet

Models will keep getting bigger context windows. They will *not* get cheaper per token at the same pace. So the discipline of **searching before reading** isn't going away — it's going to matter more, not less.

If I can make that discipline portable across Claude, Codex, Antigravity, and Cursor, then "agentic coding" stops being "which model do I trust" and starts being "which environment respects my tokens."

That's the bet.

## Try It Today

Right now Claude Turbo Search works on Claude Code. Install it:

```bash
claude plugin marketplace add iagocavalcante/claude-turbo-search
claude plugin install claude-turbo-search@claude-turbo-search-dev
```

Then in any project, run `/turbo-index` once. After that, just keep working — the agent will start searching before reading without you needing to remind it.

If you want to follow the Codex/Antigravity/Cursor ports as they ship, star the [repo on GitHub](https://github.com/iagocavalcante/claude-turbo-search) — that's where I'll cut the releases first.

Bora testar? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iago-a-cavalcante) and tell me what your `/token-stats` look like after a week.
