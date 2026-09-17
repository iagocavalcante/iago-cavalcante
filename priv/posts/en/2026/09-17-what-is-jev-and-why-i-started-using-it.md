%{
  title: "What Is Jev (and Why I Started Using It)",
  author: "Iago Cavalcante",
  tags: ~w(ai llm typesafe jev claude-code telegram),
  description: "TypeSafe's Jev doesn't generate text. It returns a typed decision with a probability. Here's how I swapped regex and giant prompts for it in claude_notify and MiseSnag.",
  locale: "en",
  published: true
}
---

Hey, everyone!

Anyone who has put an LLM in production knows this ritual:

1. Write a huge prompt.
2. Ask the model to "respond ONLY with JSON".
3. Pray it doesn't invent a field.
4. Parse it, handle the error, and hope the result is the same next time.

It works, but it's using a cannon to kill a mosquito. Most of the time I don't want the AI to write anything. I want it to decide one small thing.

Jev is a model from TypeSafe built exactly for that. It doesn't generate text. You send a context and a question with the possible answers, and it gives you back a typed answer with a probability.

## Think of it like this

A traditional LLM is like a friend who talks too much. You ask "is the recipe in the caption?" and you get a paragraph back.

Jev is like a straight-to-the-point friend: "Yes, 97% sure." Done. Then your code decides what to do with that.

## The three kinds of question

With Jev you only ask three kinds of question:

- **Noul** (yes or no): "Does this caption have enough ingredients to build a shopping list?" → `0.97`.
- **Choice** (pick one option): "Where is the recipe?" → `comments`, with 100% confidence.
- **Score** (a rating on a scale): "How urgent is this message?" → a position on a scale you define yourself.

To build a question you send three things:

1. **The state**, meaning the context: the caption, the message, whatever it is.
2. **The instruction**, which is the question itself.
3. **The criteria**, which say what each answer means.

## Real example: claude_notify

In my Telegram bot that controls Claude Code, when it asks for permission to run a command, it used to only understand `y`, `yes` or `1`. If I replied "sure, go ahead", the bot didn't get it and typed the whole text into the terminal.

Now Jev interprets the reply:

- **"sure, go ahead"** → approve (`1.0`). The bot presses Yes.
- **"ok, but don't touch the migrations"** → approve with instruction. The bot does **NOT** press the button, because it would lose the condition I set.
- **"why does it need rm -rf?"** → question. It sends the text to Claude.

And notice I never configured Portuguese. It just understood.

## Real example: MiseSnag

In MiseSnag I used regex to decide whether a video's caption already had the recipe. If it does, I skip the download and the transcription, which is where the cost is. I tested 6 captions:

- **The regex got 2 wrong.** It didn't recognize an ingredient list without quantities, and it thought "Ingredients: see video!" was a recipe.
- **Jev got all 6 right.** And as a bonus it told me where the recipe was: in the comments, on screen, or spoken.

Every regex mistake costs money: a download, a Whisper run, an LLM call for nothing.

## What I like the most

1. **The code stays in control.** Jev gives its opinion and the code decides. I'm the one who sets "only press the button if you're 90% sure". Below that, I fall back to the old behavior, which is safe.
2. **It's fast.** Around 0.9s per call, and you can send several questions in the same request.
3. **No fragile JSON parsing.** The answer already comes in the right shape.
4. **Probability becomes a business rule.** You can tune the confidence thresholds without touching a single prompt.

## Where NOT to use it

If you need to generate text (write a recipe, translate, summarize), that's an LLM job. Jev is for judgment: classifying, routing, verifying, choosing between options.

The rule I'm following:

> **LLM to write. Jev to decide. Code to execute.**

Fewer giant prompts, less broken parsing, and more predictable decisions.

That's it, folks! If you try Jev in one of your projects, tell me how it went on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iago-a-cavalcante).
