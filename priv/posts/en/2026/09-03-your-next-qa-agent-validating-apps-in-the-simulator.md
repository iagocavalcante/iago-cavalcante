%{
  title: "Your Next QA Teammate Could Be an Agent: Validating Apps in the Simulator with Claude or Codex",
  author: "Iago Cavalcante",
  tags: ~w(ai qa testing mobile claude codex mcp simulators automation),
  description: "How to connect Claude or Codex to a simulator, turn requirements into executable scenarios, and build a mobile QA loop with evidence, logs, and regression tests.",
  locale: "en",
  published: false
}
---

Hey, everyone!

You know that moment when you finish a mobile feature, run the test suite, see everything green, and still open the app to check it “one more time”?

You log in. Tap three buttons. Go back one screen. Change the language. Close and reopen the app. Turn on airplane mode. By the time you notice, you have spent half an hour repeating a checklist that exists only in your head.

That is when I started looking at Claude and Codex differently.

Instead of using an agent only to write code, why not give it access to the simulator and ask it to validate the app the way a QA engineer would?

I do not mean sending a prompt like “test my app” and trusting a reply that says “everything looks fine.” The interesting part is building a loop where the agent can:

1. Build and launch the application
2. Read the screen's accessibility tree
3. Tap, type, scroll, and navigate
4. Capture screenshots and logs
5. Compare the result against acceptance criteria
6. Fix the problem and repeat the exact same flow

This changes the development dynamic quite a bit. The agent is no longer just the one implementing the feature. It also becomes the one trying to prove that the implementation works.

In this article, I will walk through a general strategy for doing that. It works for native apps, React Native, Flutter, or any other stack that can run on an iOS Simulator or Android Emulator.

## The Problem Is Not a Lack of Tests

Almost every mobile project has some level of automated testing.

We have unit tests for business rules, integration tests for APIs, and, in some cases, end-to-end tests with Maestro, Detox, or Appium.

Even then, plenty of bugs still slip through:

- a button is hidden by the keyboard
- the session disappears after restarting the app
- a loading state never ends when the API fails
- a translated string breaks the layout
- the back button opens the wrong screen
- a permission is denied and the app does not explain how to continue
- the feature works in isolation but fails in the user's real flow

This happens because there is still a gap between “the code passed its tests” and “a person was able to use the app.”

QA in the simulator helps close that gap. A coding agent is particularly useful here because it can observe both sides at once: the interface that failed and the code that produced it.

## The Agent Needs Eyes, Hands, and Memory

Claude and Codex cannot magically control your application on their own. They need tools.

You can think of the setup as three layers:

```text
Claude or Codex
      |
      | prompt + acceptance criteria
      v
MCP, skill, or terminal commands
      |
      | build, snapshot, tap, type, swipe, logs
      v
iOS Simulator or Android Emulator
```

On iOS, an MCP server such as XcodeBuildMCP can expose builds, app launches, screenshots, the UI hierarchy, logs, and the debugger to the agent. OpenAI has an official [Codex and iOS Simulator use case](https://learn.chatgpt.com/use-cases/ios-simulator-bug-debugging) that follows this kind of workflow.

With Claude Code, the [Model Context Protocol](https://docs.anthropic.com/en/docs/mcp) connects external tools to the agent. That tool can be an existing MCP server or a small internal server that wraps the commands your project already uses.

On Android, you can build the same idea on top of `adb`, UI Automator, Maestro, or another driver that can inspect and control the emulator.

The tool's name matters less than its contract. The agent needs a small set of operations that it can perform reliably:

```text
build_app
boot_device
install_app
launch_app
read_ui_tree
tap_element
type_text
swipe
take_screenshot
read_logs
reset_app_state
```

It looks simple, but this list is already enough to validate a large part of an app.

## Do Not Start with “Test Everything”

This is probably the worst possible prompt:

```text
Test my entire application and fix any problems you find.
```

The agent does not know what “entire” means. It also does not know which data it can create, which account it should use, which screens are critical, or when a visual difference is actually a bug.

A good QA run starts with a scenario, an initial state, and an expected result.

For example:

```text
Validate the password recovery flow on an iPhone 16 running iOS 26.

Preconditions:
- use the qa@example.com account
- start with the app signed out
- do not send real emails

Acceptance criteria:
- an invalid email shows an inline field error
- a valid email opens the confirmation screen
- returning to login preserves the typed email
- no unexpected errors appear in the logs

Deliver:
- steps performed
- screenshots of important states
- the result of each acceptance criterion
- logs related to any failure
- files changed if a fix is required
```

Now there is a verifiable contract.

The agent knows where to begin, what it is allowed to do, and which evidence it needs to deliver.

## The Loop I Use

A reliable agent-driven QA flow has six stages.

### 1. Prepare a Known State

Before testing, the agent needs to know whether it should clear the app, preserve a session, or load a fixture.

Without that instruction, the same scenario may pass in one run and fail in the next simply because the simulator kept old data.

Some useful options are:

- uninstall and reinstall the app
- clear test storage and keychain data
- use dedicated QA accounts
- reset the local database
- start a fake API with known responses
- open the app through a specific deep link

The goal is not to erase everything every time. The goal is to make the initial state explicit.

### 2. Confirm the Screen Before Interacting

The agent should capture a screenshot or read the UI tree before the first tap.

This prevents a common failure: trying to tap a button using coordinates that belonged to the previous screen.

Whenever the interface changes, the agent reads the hierarchy again.

It is also worth adding `accessibilityLabel`, `accessibilityIdentifier`, `testID`, or the equivalent in your stack to important elements. Coordinates break when the device size changes. Semantic identifiers survive.

### 3. Perform One Action at a Time

The agent acts, observes the result, and only then continues.

```text
read screen
  -> tap “Sign in”
  -> read new screen
  -> enter email
  -> read form state
  -> submit
  -> capture result
```

This cadence may look slower, but it saves time when something fails. You know exactly which action changed the state.

### 4. Collect Evidence While the Bug Is Happening

A screenshot helps, but not every bug is visual.

A good run can combine:

- screenshots before and after the action
- the accessibility tree
- application logs
- requests and responses from the test API
- a crash stack trace
- persisted device state
- a short video of the flow when useful

The goal is to move from “it failed” to “it failed after this action, in this state, with this log.”

### 5. Make the Smallest Possible Fix

If the agent can also edit the project, it should reproduce the failure before touching the code.

That order makes all the difference.

Without reproduction, the agent may fix a hypothesis. With reproduction, it can compare the behavior before and after the change.

I also keep the scope small: one bug per run. Mixing login, notifications, layout, and caching in a single run makes it difficult to know which change solved which problem.

### 6. Repeat the Same Path

After the fix, compiling is not enough.

The agent should reset the necessary state and repeat the path that failed. Same account. Same device. Same steps. Same acceptance criteria.

At the end, I want a report that looks like this:

```text
Device: iPhone 16, iOS 26.0
Build: a1b2c3d
Scenario: password recovery

PASS - invalid email shows an inline error
PASS - valid email opens confirmation
PASS - returning to login preserves the email
PASS - no unexpected errors in the logs

Evidence:
- artifacts/password-invalid.png
- artifacts/password-confirmation.png
- artifacts/simulator.log
```

Now we have evidence, not just confidence.

## Build a Small, Useful Matrix

Validating every combination of device, operating system, and state is not practical. The trick is choosing a matrix that represents real risk.

I would start with this:

| Area | Minimum scenario |
| --- | --- |
| Onboarding | first launch, skip, and complete |
| Authentication | successful login, error, and logout |
| Core flow | the path that delivers the app's main value |
| Persistence | close, reopen, and restore state |
| Permissions | allow, deny, and try again |
| Network | offline, timeout, and invalid response |
| Layout | small device, larger font, and another language |
| Navigation | back, deep link, and returning from background |

You do not need to run everything on every commit.

The critical happy path can run all the time. Error scenarios and the visual matrix can run before a release or whenever the corresponding area changes.

## Turn Discoveries into Regression Tests

This is my favorite part of the flow.

An agent is good at exploration. It can inspect the screen, interpret an unusual state, and decide which path to try next.

But we should not spend LLM reasoning on repeating the same login forever.

Once a scenario becomes stable, turn it into a deterministic test using the project's E2E tool.

```text
agent explores
  -> finds a bug
  -> reproduces it with evidence
  -> fixes it
  -> writes a regression test
  -> CI repeats it without an LLM
```

The agent discovers. The automated test protects.

This split keeps the cost predictable and reduces flakiness. It also prevents Claude or Codex from becoming an expensive robot that keeps clicking through the same screens.

## Put the Rules in the Repository

If every session needs to relearn how to test your app, you still have a manual process.

Document the rules in `AGENTS.md`, `CLAUDE.md`, or a project skill.

Here is a simple example:

```markdown
## Mobile QA

- Always use the qa@example.com account.
- Never run destructive flows in production.
- Prefer accessibility IDs; do not use coordinates when a selector exists.
- Save evidence under artifacts/qa/<scenario>/.
- Record the device, OS, build, and initial state.
- Reproduce the bug before changing code.
- Repeat the same flow after the fix.
- Run one scenario at a time.
```

You can go further and create commands such as:

```text
./scripts/qa/reset-app
./scripts/qa/start-fixtures
./scripts/qa/collect-logs
./scripts/qa/run-critical-path
```

The easier it is to prepare and observe the environment, the better the agent performs.

This does not benefit only AI. A new person on the team can also reproduce the scenario without depending on tribal knowledge.

## Where the Simulator Is Not Enough

There is one important limit: a simulator is not a real device.

I would not use this flow as the only validation for:

- push notifications delivered through APNs or FCM
- camera, microphone, Bluetooth, and NFC
- real biometrics
- battery and memory consumption
- performance on entry-level devices
- behavior on an unstable cellular network
- store purchases and subscriptions
- background execution controlled by the operating system
- differences between Android manufacturers

The simulator is great for navigation, states, forms, layout, persistence, and many integration failures. For physical capabilities or system-specific behavior, we still need a canary run on a real device.

I would not remove human review either. An agent can prove that a button works, but it cannot decide on its own whether the experience is clear, pleasant, and consistent with the product.

## The Practical Result

When this loop works, you are not getting an “artificial QA” that replaces a person.

You are getting a low-cost way to remove repetitive work from the team's head.

The developer describes the expected behavior. The agent prepares the simulator, performs the flow, collects evidence, and points to where the contract broke. If it is allowed to fix the problem, it makes the smallest change and repeats the same path.

Then the important scenario becomes a deterministic regression test.

It is a simple combination:

```text
unit tests guarantee rules
integration tests guarantee contracts
E2E guarantees known flows
the agent explores what has not become a test yet
a real device validates what the simulator cannot represent
```

No single layer solves everything. Together, they make a release much less dependent on someone saying, “open it quickly and see if it works.”

That is it, folks!

If you have already connected Claude or Codex to a simulator, tell me how you built your loop. Reach out on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iago-a-cavalcante).

Ready to test it?
