%{
  title: "Interfaces and Contracts: How Agents Respect Boundaries",
  author: "Iago Cavalcante",
  tags: ~w(ai software-engineering rfcs prompts agents development),
  description: "Without explicit contracts, each agent invents its own interface. The result? Systems that work alone but break together.",
  locale: "en",
  published: false,
  scheduled_for: ~D[2026-03-12]
}
---

Hey folks! Today I want to start with a scenario that everyone who has worked with microservices has lived through at least once.

Two teams. Two services. A tight deadline. Each team works in their own corner for two weeks. On integration day, they wire the two services together and... nothing works.

Service A sends `user_id` as a string. Service B expects an integer. Service A returns errors with an `error_message` field. Service B looks for `error`. Service A uses `/api/v1/users/:id`. Service B calls `/users/get`. And so on.

Each service works perfectly on its own. Together, they're incompatible.

Now swap "two teams" for "two prompts given to an AI agent" and the scenario is exactly the same.

## The implicit interface problem

When two teams don't define an explicit interface before they start coding, each one invents their own. And since each team has different contexts, experiences, and preferences, the invented interfaces are rarely compatible.

With humans, this is inconvenient but recoverable. The devs sit together, look at the contracts, negotiate, adjust. Takes a day, maybe two. Frustrating, but doable.

With AI agents, the problem runs deeper. The agent doesn't negotiate. It doesn't look at the other service's code to figure out how to adapt. When it receives a prompt saying "create a user service," it generates the interface it considers most likely based on what it learned. And when another prompt asks "create an order service that consumes the user service," the second agent invents *its own version* of how the user service should work.

The result is the same as the two teams: two systems that work in isolation and break on integration.

## Interface-first: the RFC lesson

In software engineering, this problem was solved decades ago. The solution has a simple name: **contract-first design** -- or, in RFC world, defining interfaces before implementation.

The idea is straightforward. Before any team writes a single line of code, everyone agrees on the contract. The contract defines:

- **Endpoints**: which paths exist and what each one does
- **Input types**: what each endpoint receives, with exact types
- **Output types**: what each endpoint returns, for success and error cases
- **Status codes**: which HTTP responses (or equivalents) each scenario produces
- **Error format**: how errors are represented

When the contract exists before the code, each team can implement freely on the inside. They can change the internal architecture, swap the database, refactor everything -- as long as the contract is still honored. The interface is the boundary. Inside it, total freedom. Outside it, shared responsibility.

This principle is so fundamental that it shows up in virtually every well-written RFC. The "interfaces" or "API specification" section almost always comes before the implementation section.

## The same principle, applied to agents

When you ask an AI agent to create a service, the prompt is your RFC. And if the RFC doesn't define interfaces, the agent improvises.

Let's see this in practice with a concrete example.

**Team A -- prompt without a contract:**

```
Create a user service in Elixir/Phoenix that allows creating,
fetching, and updating users. Use JSON for communication.
```

**Team B -- prompt without a contract:**

```
Create an order service in Elixir/Phoenix that creates orders
for existing users. Query the user service to validate that the
user exists before creating the order.
```

What happens?

Team A's agent might return users like this:

```json
{
  "user": {
    "id": "usr_abc123",
    "full_name": "Maria Silva",
    "email": "maria@example.com",
    "created_at": "2026-03-12T10:00:00Z"
  }
}
```

And Team B's agent might generate code that expects this:

```json
{
  "data": {
    "user_id": 42,
    "name": "Maria Silva",
    "email": "maria@example.com"
  }
}
```

The `id` field became `user_id`. The type changed from string to integer. The wrapper changed from `user` to `data`. The field `full_name` became `name`. None of these decisions are "wrong" in isolation -- they're all valid choices. But together, they're incompatible.

## The contract as the prompt's foundation

The solution is the same in both worlds: define the contract first. But in the agent world, the contract needs to live **inside the prompt**.

Here's how the same scenario works when you include the contract:

**Shared contract (included in both prompts):**

```
## User API Contract

### GET /api/v1/users/:id
Success response (200):
{
  "id": integer,
  "name": string,
  "email": string
}

Error response (404):
{
  "error": "not_found",
  "message": string
}

Error response (422):
{
  "error": "validation_failed",
  "details": [{"field": string, "message": string}]
}

### POST /api/v1/users
Expected body:
{
  "name": string (required, max 100),
  "email": string (required, email format)
}

Success response (201): same format as GET
```

**Team A -- prompt with contract:**

```
Create the user service in Elixir/Phoenix.
Implement the endpoints according to the contract below.
Do NOT change field names, types, or endpoint paths.

[contract above]
```

**Team B -- prompt with contract:**

```
Create the order service in Elixir/Phoenix.
When validating that the user exists, call the user service
according to the contract below. Use exactly the fields and types
defined in the contract to parse the response.

[contract above]
```

Now both agents work from the same source of truth. Service A implements the interface exactly as defined. Service B consumes the interface exactly as defined. Integration works on the first try.

## Type specs as contracts in Elixir

If you work with Elixir, you already have a powerful tool for defining contracts: **typespecs**. And they work remarkably well inside prompts.

Instead of describing the interface in free-form text, you can include specs that the agent will respect:

```elixir
@type user :: %{
  id: integer(),
  name: String.t(),
  email: String.t()
}

@type error_response :: %{
  error: String.t(),
  message: String.t()
}

@spec get_user(integer()) :: {:ok, user()} | {:error, error_response()}
@spec create_user(map()) :: {:ok, user()} | {:error, error_response()}
```

When you include this in the prompt, you're giving the agent a contract with the precision of a programming language, not the ambiguity of prose. The agent knows exactly that `get_user` receives an integer and returns a tuple with a map of specific fields.

It's the difference between saying "return the user data" and saying "return `{:ok, %{id: integer(), name: String.t(), email: String.t()}}` or `{:error, %{error: String.t(), message: String.t()}}`". The second version leaves no room for interpretation.

## The contract-first template for prompts

After applying this pattern across several projects, I've arrived at a template that works consistently:

```
## Context
[What the service does and where it fits in the system]

## Interface Contracts

### Interfaces this service EXPOSES
[Endpoints, input types, output types, error codes]

### Interfaces this service CONSUMES
[External endpoints it calls, with expected response formats]

## Implementation Rules
[How the service should work internally]

## Out of Scope
[What NOT to implement]
```

The contracts section comes before the implementation rules. This is intentional. The contract defines the shape; the implementation fills in the behavior. The agent reads the contract first and already knows the boundaries before it starts writing code.

## Why explicit contracts matter more for agents than for humans

A human dev, when they hit an integration inconsistency, does what any professional does: investigate, ask, adapt. They open the other service's code, read the docs, fire off a Slack message. It's a slow process, but it works.

The agent does none of that. It works with what it has in the prompt. If the prompt doesn't have the contract, it invents one. And what it invents is based on statistical patterns from millions of repositories -- meaning it'll be something reasonable, but it won't be *your* contract.

This means that, paradoxically, explicit contracts matter **more** for agents than for humans. Humans compensate for missing contracts with informal communication. Agents don't have that option.

## The cascade effect

A poorly defined interface in a prompt doesn't just break one service. It breaks everything that depends on it.

If the agent generates a user service with different fields than expected, the order service breaks. If the order service is broken, the payment service that depends on it breaks too. And if you're using agents to generate multiple services simultaneously, every implicit interface is a ticking time bomb.

The contract-first approach prevents the cascade at its root. When all contracts are defined before implementation, each agent can work independently without risk of incompatibility. It's the same principle that allows distributed teams to work in parallel -- the contract is the synchronization point.

## What's coming next

In the next article, we'll talk about **acceptance criteria** -- how to define, in a clear and verifiable way, when the agent's work is complete. If interfaces say how the pieces connect, acceptance criteria say when each piece is ready.

---

### Series: RFCs as Prompts for AI-Agent Development

1. [The fundamental connection](/blog/the-rfc-nobody-read-and-the-prompt-nobody-wrote)
2. [Anatomy of a good RFC](/blog/the-anatomy-of-a-good-rfc)
3. [Anatomy of a good system prompt](/blog/the-anatomy-of-a-good-system-prompt)
4. [Explicit constraints — The power of "don't do this"](/blog/explicit-constraints-the-power-of-dont-do-this)
5. **Interfaces and contracts — How agents respect boundaries** *(this article)*
6. Acceptance criteria *(coming soon)*
7. Feedback loops *(coming soon)*
8. Shared context *(coming soon)*
9. The unified document *(coming soon)*
10. The future of specification *(coming soon)*

---

Enjoyed this? Want to discuss contracts, interfaces, or service integration? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).
