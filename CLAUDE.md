# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Phoenix/Elixir Application (Root)
- **Setup**: `mix setup` - Install dependencies and setup database
- **Development**: `mix phx.server` or `iex -S mix phx.server` - Start server at localhost:4000
- **Tests**: `mix test` - Run test suite with database setup
- **Assets**: `mix assets.setup` - Install Tailwind and esbuild
- **Deploy**: `mix assets.deploy` - Build and optimize frontend assets
- **Database**: `mix ecto.reset` - Drop and recreate database

### React Native Todo App (todo-app-mvvm/)
- **Development**: `npm start` or `expo start` - Start Expo development server
- **Platform Specific**: `npm run ios`, `npm run android`, `npm run web`
- **Linting**: `npm run lint` - Run ESLint

## Architecture

### Main Phoenix Application
**Context-Based Architecture**: Business logic separated into contexts (`lib/iagocavalcante/`)
- `accounts/` - User authentication and management
- `blog/` - Static blog engine using NimblePublisher with Markdown posts
- `clients/` - External API integrations (Cloudflare Stream)

**Web Layer** (`lib/iagocavalcante_web/`):
- Phoenix LiveView for real-time interactive components
- Controllers for HTTP endpoints
- Reusable UI components
- Multi-language support (English/Portuguese)

**Content Management**:
- Blog posts stored as Markdown in `/priv/posts/` organized by language and year
- Static site generation at build time
- AWS S3 integration for file uploads
- Cloudflare Stream for video content

### Todo App (MVVM Pattern)
**Architecture**: Model-View-ViewModel with dependency injection
- **State Management**: MobX for reactive state
- **DI Container**: Inversify for dependency injection
- **Navigation**: Expo Router with React Navigation
- **Storage**: AsyncStorage for persistence

## Key Configuration
- **Database**: PostgreSQL with Ecto migrations
- **Authentication**: bcrypt_elixir with email confirmation
- **Deployment**: Fly.io (fly.toml) and Kubernetes manifests (k8s/)
- **Styling**: Tailwind CSS with dark mode support
- **Email**: Swoosh with Resend integration

## Coding Standards

### Phoenix LiveView (CRITICAL)
```
NO DATABASE QUERIES IN MOUNT
```
- `mount/3` is called TWICE (HTTP + WebSocket). Queries in mount = duplicate queries.
- Use `handle_params/3` for all data loading
- Use `assign_async/3` for data that can load after initial render

```elixir
# ❌ WRONG
def mount(_params, _session, socket) do
  bookmarks = Bookmarks.list_bookmarks(user_id)  # Called twice!
  {:ok, assign(socket, bookmarks: bookmarks)}
end

# ✅ CORRECT
def mount(_params, _session, socket) do
  {:ok, assign(socket, bookmarks: [], loading: true)}
end

def handle_params(_params, _uri, socket) do
  bookmarks = Bookmarks.list_bookmarks(socket.assigns.current_user.id)
  {:noreply, assign(socket, bookmarks: bookmarks, loading: false)}
end
```

### Ecto Patterns

**Changeset Separation**: Use multiple changesets per schema:
- `create_changeset/2` - Full validation for new records
- `update_changeset/2` - For content updates
- `status_changeset/2` - Lightweight for status changes only

**Ecto.Enum**: Always use atoms for status fields:
```elixir
@statuses ~w(pending approved rejected)a
field :status, Ecto.Enum, values: @statuses, default: :pending
```

**Cross-Context References**: Use plain field IDs, not belongs_to:
```elixir
# ❌ WRONG - couples contexts
belongs_to :user, Accounts.User

# ✅ CORRECT - keeps contexts independent
field :user_id, :id
```

### Security Requirements (CRITICAL)

**Null Byte Sanitization**: PostgreSQL crashes on null bytes. Sanitize ALL user input:
```elixir
# Use the Sanitizer module for changesets
alias Iagocavalcante.Ecto.Sanitizer

def changeset(struct, attrs) do
  struct
  |> cast(attrs, [:field1, :field2])
  |> Sanitizer.sanitize_fields([:field1, :field2])
  |> validate_required([:field1])
end

# For inline sanitization (search, filters)
sanitized = String.replace(user_input, "\0", "")
```

**Path Validation**: For any file operations:
```elixir
expanded = Path.expand(user_path)
unless String.starts_with?(expanded, allowed_base), do: raise "path traversal"
```

### Task Supervision
Never use fire-and-forget tasks in production:
```elixir
# ❌ WRONG
Task.start(fn -> send_email() end)

# ✅ CORRECT
Task.Supervisor.start_child(Iagocavalcante.TaskSupervisor, fn -> send_email() end)
```

### Project Modules

| Module | Purpose |
|--------|---------|
| `Iagocavalcante.Ecto.Sanitizer` | Null byte sanitization for changesets |
| `Iagocavalcante.TaskSupervisor` | Supervised async tasks |
| `Iagocavalcante.Bookmarks.Cache` | ETS cache for CSV bookmarks |
| `Iagocavalcante.Blog.SpamDetector` | Spam scoring for comments |

### Testing Patterns
- Always use `async: true` unless testing global state
- Use factories for test data, not fixtures
- Test behavior (public API), not implementation