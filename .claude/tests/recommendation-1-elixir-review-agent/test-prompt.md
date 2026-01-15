# Test Prompt for Elixir Code Review Agent

## Test Case
Simulate a code review request for the recently modified Comment schema.

## Prompt
```
Review the changes I made to lib/iagocavalcante/blog/comment.ex - specifically the changeset patterns and spam detection integration. Check for:
1. Proper changeset separation
2. Null byte sanitization coverage
3. Phoenix/Ecto best practices
4. Any security concerns
```

## Expected Behaviors

### BEFORE (without custom Elixir review agent)
- General code review without Elixir-specific patterns
- May miss Phoenix LiveView conventions
- Won't reference project-specific patterns
- Generic suggestions without context

### AFTER (with custom Elixir review agent)
- Checks against Phoenix patterns (mount rules, etc.)
- Validates Ecto changeset patterns (multiple changesets, Enum usage)
- Enforces null byte sanitization at boundaries
- References our established patterns from previous work
- Categorizes issues as Critical/Warning/Suggestion

## Evaluation Criteria
1. Does it catch Elixir-specific anti-patterns?
2. Does it reference our project's established patterns?
3. Does it provide actionable, categorized feedback?
4. Does it validate against security patterns (null bytes, SQL injection)?
