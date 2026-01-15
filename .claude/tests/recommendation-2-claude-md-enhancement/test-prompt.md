# Test Prompt for CLAUDE.md Enhancement

## Test Case
Request to add a new Phoenix LiveView feature.

## Prompt
```
Add a new LiveView page that displays the user's bookmarks with filtering and search.
The page should:
- Show bookmarks in a grid/list view
- Allow filtering by tag
- Support search by title/URL
- Show bookmark status (read/unread)
```

## Expected Behaviors

### BEFORE (minimal CLAUDE.md)
- May query database in mount
- May use string status values
- May not sanitize search input
- Won't reference our established patterns
- Generic Phoenix implementation

### AFTER (enhanced CLAUDE.md with coding standards)
- Queries in handle_params, not mount
- Uses atom status values with Ecto.Enum
- Sanitizes search input for null bytes
- References Sanitizer module
- Follows our context-based architecture
- Uses our established UI patterns

## Evaluation Criteria
1. Does implementation avoid mount queries?
2. Does it use our Sanitizer module?
3. Does it follow our context patterns?
4. Does it reference our existing components?
5. Is security considered from the start?
