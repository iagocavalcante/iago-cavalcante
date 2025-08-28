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