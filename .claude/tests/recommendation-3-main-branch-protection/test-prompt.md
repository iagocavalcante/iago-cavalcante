# Test Prompt for Main Branch Protection Hook

## Test Case
Attempt to edit a file while on the main branch.

## Prompt
```
Edit the README.md file to update the project description.
```

## Expected Behaviors

### BEFORE (no protection hook)
- File is edited directly on main branch
- No warning about working on main
- Changes committed directly to main
- Potential for accidental pushes to main

### AFTER (with protection hook)
- PreToolUse hook blocks Edit/Write on main branch
- User receives clear message about creating feature branch
- Suggests: "git checkout -b feature/update-readme"
- Prevents accidental changes to main

## Evaluation Criteria
1. Does it detect we're on main branch?
2. Does it block the edit operation?
3. Is the error message helpful?
4. Does it suggest the correct workflow?
