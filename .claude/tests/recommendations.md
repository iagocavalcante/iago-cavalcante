# Claude Code Setup Improvement Recommendations

Based on analysis of the claude-code-showcase repository and our current setup.

## Current Setup Summary

### What We Have
1. **CLAUDE.md** - Basic project memory with commands and architecture
2. **User-level skills** (3):
   - `write-like-iago` - Personal writing style
   - `social-cta-brainstorm` - Social media CTA generation
   - `lovable-web-development` - Design-system-first approach
3. **Plugins** (active):
   - superpowers (workflows, planning, debugging)
   - elixir (6 Elixir/Phoenix/Ecto thinking skills)
   - frontend-design
   - code-simplifier
   - cartographer
4. **Project-level .claude/** - Only permissions in settings.local.json

### What's Missing (vs. Showcase Best Practices)

## Recommendations

### 1. **Elixir-Specific Code Review Agent** (HIGH PRIORITY)
**Why:** The showcase has a `code-reviewer.md` agent with framework-specific patterns. Our codebase is Phoenix/Elixir but lacks a reviewer that knows our patterns.

**What to add:**
- Phoenix LiveView patterns (no queries in mount)
- Ecto changeset patterns (null byte sanitization, multiple changesets)
- OTP supervision tree patterns
- Context boundary violations

### 2. **Project-Level CLAUDE.md Enhancement** (HIGH PRIORITY)
**Why:** Showcase recommends including coding standards and critical constraints. Our CLAUDE.md is minimal.

**What to add:**
- Elixir idioms we follow
- Phoenix LiveView patterns
- Security constraints (null byte, SQL injection prevention)
- Testing requirements

### 3. **PostToolUse Hook for mix format** (MEDIUM PRIORITY)
**Why:** Showcase auto-formats on file save. We have mix-format plugin but no automatic trigger.

**What to add:**
- Run `mix format` after Edit/Write on `.ex`, `.exs` files
- Run `mix compile --warnings-as-errors` to catch issues early

### 4. **PreToolUse Hook for Main Branch Protection** (MEDIUM PRIORITY)
**Why:** Showcase blocks edits on main/master branch, suggesting feature branches.

**What to add:**
- Block Edit/Write when on `main` branch
- Suggest creating feature branch

### 5. **PR Review Command** (LOW PRIORITY)
**Why:** Showcase has `/pr-review` command that loads standards and reviews PRs.

**What to add:**
- Elixir-specific checklist
- Integration with our code-reviewer agent

### 6. **Custom Elixir Testing Skill** (LOW PRIORITY)
**Why:** Our test patterns (async: true, factory functions, Mox) could be codified.

**What to add:**
- ExUnit best practices
- Factory patterns
- Mox mocking patterns

---

## Testing Framework

For each recommendation, we will:
1. Create a BEFORE file with a test prompt response (without the change)
2. Apply the change
3. Create an AFTER file with the same test prompt response
4. Analyze the difference

### Test Prompts by Recommendation

| Recommendation | Test Prompt |
|---------------|-------------|
| 1. Code Review Agent | "Review the changes I just made to the Comment schema" |
| 2. CLAUDE.md Enhancement | "Add a new LiveView that shows user bookmarks" |
| 3. mix format Hook | "Fix the changeset in bookmark.ex" |
| 4. Main Branch Protection | "Edit the README.md file" (while on main) |
| 5. PR Review Command | "/pr-review" |
| 6. Testing Skill | "Write tests for the Bookmarks context" |
