# AFTER: Main Branch Protection Hook

## Test Execution Date
2026-01-14

## New Setup
- Created `.claude/hooks/protect-main-branch.sh`
- Created `.claude/hooks/hooks.json` configuration
- Hook triggers on Edit, MultiEdit, Write tool calls

## Hook Test Result

```bash
$ .claude/hooks/protect-main-branch.sh
{
  "decision": "block",
  "reason": "You're on the 'main' branch. Create a feature branch first:\n\ngit checkout -b feature/your-change-description\n\nThis prevents accidental commits to main."
}
# Exit code: 2 (blocking error)
```

## Simulated Behavior

When asked to edit README.md while on main branch:

### What Happens
1. Claude receives the edit request
2. PreToolUse hook fires before Edit tool
3. Hook detects current branch is "main"
4. Returns blocking JSON with helpful message
5. Claude cannot proceed with edit
6. User sees suggestion to create feature branch

### Benefits

| Benefit | Description |
|---------|-------------|
| Prevents accidents | Can't accidentally edit files on main |
| Enforces workflow | Requires feature branches |
| Clear guidance | Provides exact command to run |
| Non-intrusive | Silent pass on feature branches |

## Metrics

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Branch safety | 0/10 | 9/10 | +9 |
| Workflow guidance | 0/10 | 8/10 | +8 |
| Error prevention | 0/10 | 9/10 | +9 |
| Developer experience | 5/10 | 7/10 | +2 |

## Implementation Details

### Files Created

1. `.claude/hooks/protect-main-branch.sh`:
   - Checks current git branch
   - Returns blocking JSON if on main/master
   - Suggests feature branch command
   - Exit code 2 for blocking, 0 for allow

2. `.claude/hooks/hooks.json`:
   - Configures PreToolUse hook
   - Matches Edit, MultiEdit, Write tools
   - 5 second timeout

### Hook Behavior Matrix

| Branch | Edit | Write | MultiEdit |
|--------|------|-------|-----------|
| main | ❌ Block | ❌ Block | ❌ Block |
| master | ❌ Block | ❌ Block | ❌ Block |
| feature/* | ✅ Allow | ✅ Allow | ✅ Allow |
| develop | ✅ Allow | ✅ Allow | ✅ Allow |

## Conclusion

The main branch protection hook provides:
1. **Safety net** - Prevents accidental main branch edits
2. **Workflow enforcement** - Encourages feature branch usage
3. **Clear messaging** - Users know exactly what to do
4. **Minimal friction** - Only blocks on protected branches

**Recommendation: MEDIUM IMPACT - Implement this change**

Note: Impact is medium because:
- Adds safety but requires workflow change
- Some users may find it annoying initially
- Benefits compound over time as team grows
