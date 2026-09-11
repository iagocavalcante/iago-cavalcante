%{
  title: "From Build to Store: Automating App Publishing with Computer Use, Codex, and Claude",
  author: "Iago Cavalcante",
  tags: ~w(ai mobile codex claude computer-use automation app-store deploy),
  description: "How to combine the terminal, browser automation, and computer use to prepare releases, fill in store metadata, and submit apps for review without exposing sensitive data.",
  locale: "en",
  published: true
}
---

Hey, everyone!

The build passed. The app opened in the simulator. The tests are green.

Then you open the store dashboard and start another journey: choose the version, check screenshots, fill in the description, update the localizations, and figure out which field is blocking submission.

In my recent agent sessions, this part became automatable too. In one of them, the agent operated App Store Connect through the browser, updated copy in four languages, and submitted the version for review.

The recorded result was **submitted for review**. Apple’s approval was still pending.

I want to show how to organize this workflow with Codex or Claude. The examples are generalized: no project names, account identifiers, credentials, or user data.

## Where computer use fits

Computer use lets an agent observe an interface and interact with it: click, type, scroll, and verify the result. Availability and setup depend on the product and environment.

For Codex, see the [official OpenAI Computer Use documentation](https://learn.chatgpt.com/docs/computer-use). With Claude, there are paths such as [computer use in Cowork](https://support.claude.com/en/articles/14128542-let-claude-use-your-computer-in-cowork) and the [computer use tool through the API](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool). With the API route, your application executes the actions requested by the model and returns the results.

Simply typing “use my computer” into a chat does not connect an agent to your desktop.

Browser automation can operate page elements directly. Computer use can work through the visual interface. In the sessions I checked, the submission is recorded as browser automation; that does not prove that every click happened through screenshot recognition.

I would combine the tools like this:

| Stage | Preferred path |
| --- | --- |
| Tests, version, and build | Project commands and CI |
| Signing and upload | Official tools or the project’s existing integration |
| Metadata and dashboard navigation | API or browser automation when available |
| Interactions that require visual context | Computer use |
| Final verification | Store status and execution evidence |

If the project already has a reliable build command, let the agent use it. There is no reason to open menus to repeat something that is already solved.

## Define what “publish” means

“Upload the app” can mean several different things: send a binary, make a build available for testing, submit it for review, or release an update to the public.

On Apple’s side, an uploaded build must be processed before it appears in App Store Connect. You then select the build and submit the version. Apple documents [uploading builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds) and [submitting for review](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app) as separate steps.

I would start with a request like this:

```text
Prepare the next iOS version for review.

Use the commit and version defined in the release document.
Run the checks already present in the project.
Build and upload using the configured workflow.
Verify processing and prepare the App Store Connect metadata.

Before submission, show:
- selected version and build;
- copy and screenshots that will be submitted;
- any pending issues;
- the release setting after approval.

Stop here for my review.
Do not change prices, contracts, or declarations without validated information.
Do not expose credentials in logs or in your response.
```

This gives the agent a verifiable destination and defines the authorization boundary for that run.

## Prepare the material first

Keep a small release document in the repository with the version, code reference, locales, release notes, and paths to approved screenshots.

Credentials stay in the project’s existing secure mechanism. The document only needs to say which configuration to use, without copying secret values.

Complete login and two-factor authentication through the normal tool flow. If the session expires, authenticate again; never turn a password or temporary code into a persistent instruction.

Use fictional data in screenshots. Before sharing evidence, check for emails, account identifiers, notifications, or private information.

## Observe, fill, save, verify

The dashboard loop is small:

```text
observe the current page
  -> confirm app, version, and locale
  -> fill one section
  -> save
  -> verify errors and persisted content
  -> continue to the next section
```

Prefer identifiable page elements. If an interaction depends on coordinates, observe the screen again after a layout change.

A clicked button does not prove that a form was saved.

The four-locale session had real metadata work to repeat. That is a good automation candidate: the agent can visit each locale and verify that the corresponding copy landed in the right place.

One session also showed trouble saving a description with particular formatting during browser automation. The lesson is to inspect both the error and the persisted text. A single incident is not enough to claim that a store bans that character in every context.

## Review feedback can point back to the product

In another session, a rejection said that an integration in the app was not identifiable in the interface.

The work involved making the feature visible, adjusting its behavior, adding tests, and preparing another build.

If the store reports a product issue, repeating the submission will not fix it. The agent needs to connect the feedback to the code, reproduce the scenario, validate the fix, and only then prepare another submission.

That is the same evidence loop used for simulator QA: observe what failed, make the smallest correction, and repeat the scenario.

## Finish with a verifiable status

After reviewing the material, you can authorize submission of that specific version. The agent then submits it and checks the result.

I would ask for a report like this:

```text
Build: processed and selected
Metadata: checked in the expected locales
Submission: sent
Observed status: Waiting for Review
Release: manual after approval
Pending: store review
```

On Apple’s side, “Waiting for Review” means the submission was received and review has not started yet. The status is described in the [App Store Connect status reference](https://developer.apple.com/help/app-store-connect/reference/app-information/app-and-submission-statuses).

The same organization works for Google Play: prepare the bundle, choose a testing track or production, and verify review and publishing steps. The confirmed session example here was iOS; Android is an adaptation of the same workflow. Google documents it in [prepare and roll out a release](https://support.google.com/googleplay/android-developer/answer/9859348?hl=en).

## Turn the working path into a reusable instruction

After one successful run, record the commands, material locations, and states that must be checked. Put them in `AGENTS.md`, `CLAUDE.md`, or a project skill.

You do not need to build a release platform. A clear workflow, configured tools, and verification at every stage are enough to start.

The practical gain is removing the sequence of opening dashboards, hunting for fields, switching locales, and checking builds from your head. You review a concrete result with visible pending items.

I would automate one update up to the human review step first. Expand the scope only after that path is reliable.

Let’s test it!
