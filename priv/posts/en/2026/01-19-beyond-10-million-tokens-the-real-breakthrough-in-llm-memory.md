%{
  title: "Beyond 10 Million Tokens: The Real Breakthrough in LLM Memory Is About Complexity, Not Just Size",
  author: "Iago Cavalcante",
  tags: ~w(ai llm rlm memory context research),
  description: "The real problem isn't context window size - it's how the model interacts with information. Recursive Language Models propose a paradigm shift that could redefine what LLMs can actually do.",
  locale: "en",
  published: true
}
---

Hey folks! You know that feeling when you feed a massive document to an LLM and it just ignores crucial details from the beginning? Or when you have a long conversation and the model "forgets" what you agreed on earlier?

There's a name for this: "context rot." And it's incredibly frustrating.

Even frontier models like GPT-5 suffer from this. Performance degrades as context grows - and it degrades even faster when the task is complex. This limited effective memory is the main bottleneck preventing LLMs from tackling truly large-scale problems, like analyzing an entire codebase or a massive research corpus.

But what if the solution wasn't just to build a bigger memory, but to fundamentally change how the LLM interacts with information?

A recent paper, "Recursive Language Models," proposes exactly that. And the results are impressive.

## 1. The Big Idea: Stop Reading and Start Programming

The core insight behind RLMs (Recursive Language Models) is to stop treating long prompts as a single text to be read at once. Instead, the RLM treats the prompt as an **external environment** that the LLM can manipulate symbolically.

Here's how it works: the RLM loads the entire prompt into a programming environment (a REPL - Read-Eval-Print Loop) as a variable. The LLM is then instructed to write code. Using this code, it can "peek into," decompose, and analyze small snippets of the massive prompt. And crucially: it can recursively call itself on these smaller pieces to solve sub-tasks.

In practice, this teaches the LLM to treat its own context not as a memory to recall, but as a **database to be queried and manipulated**.

The paper uses an analogy with "out-of-core" algorithms from data processing - where systems with small, fast memory can process huge datasets by intelligently managing how data is fetched from slower storage. The RLM does the same thing: it uses its fixed context window as a small, fast main memory to operate on a nearly limitless external prompt.

## 2. The Performance Gains Are Staggering

The results are dramatic. The research shows that RLMs can successfully handle inputs up to **two orders of magnitude beyond** the base model's context window.

The most impressive example comes from the OOLONG-Pairs task - a benchmark designed to test reasoning over **pairs** of data points in a large input. On this task:

| Model | Score |
|-------|-------|
| GPT-5 (standard) | < 0.1% |
| GPT-5 + RLM | **58.00%** F1 |

This isn't just an improvement - it's an **emergent capability**. The model gained an ability it simply didn't have before.

## 3. It's Counter-Intuitively Cheaper (Most of the Time)

Despite the complex process of writing code and making recursive calls, RLMs have "comparable or cheaper average token costs" than standard models. For GPT-5, the study found that "the median RLM run is cheaper than the median base model run."

The reason is simple: a standard LLM must ingest the entire input context, no matter how large. An RLM, on the other hand, can **intelligently and selectively** view only the most relevant parts of the context. It doesn't need to "read" the whole book if it can use code to jump directly to the right chapter.

**But there's an important caveat:** RLM costs have a long tail, with high variance. While the median run is cheaper, some outlier runs can be "significantly more expensive" due to long, complex reasoning trajectories.

## 4. The Real Enemy Isn't Length, It's Complexity

This was the finding that caught my attention the most.

The paper argues that an LLM's "effective context window" isn't a fixed number of tokens. It **shrinks** as task complexity increases.

To understand this, the researchers characterized tasks by how their complexity scales with prompt length:

**Constant Scaling:**
A simple "needle-in-a-haystack" (S-NIAH) task has constant complexity. Finding one piece of information doesn't get harder as the haystack grows. Here GPT-5 performs well.

**Linear Scaling:**
A task like OOLONG, which requires processing almost every line in the prompt to form an answer, has linear complexity. The workload grows in direct proportion to input size. Here GPT-5's performance degrades faster.

**Quadratic Scaling:**
A task like OOLONG-Pairs, which requires comparing **pairs** of entries in the dataset, has quadratic complexity. The workload explodes as input size grows. Here GPT-5's performance collapses catastrophically.

| Complexity | Example | Standard GPT-5 | GPT-5 + RLM |
|------------|---------|----------------|-------------|
| Constant | Needle-in-a-Haystack | Good | Good |
| Linear | OOLONG | Degrades | Maintains |
| Quadratic | OOLONG-Pairs | Collapses (<0.1%) | Works (58%) |

Standard LLMs are brittle against tasks with linear and especially quadratic complexity. RLMs, while not immune, show a dramatically slower rate of degradation. This ability to maintain strong performance against quadratically scaling complexity is the true breakthrough.

## 5. The LLM Starts Behaving Like a Smart Researcher

One of the most fascinating findings is that RLMs exhibit sophisticated, "emergent patterns" of reasoning and problem decomposition - without being explicitly trained for them. The model learns to manage its own cognitive load, much like a human researcher.

**Filtering with Code:**
The model uses code, such as regex queries, to search for keywords and filter the massive input context. It even uses its own priors to inform these searches, like looking for the phrase "La Union" in a geography-related task.

**Strategic Chunking:**
The model learns to break down problems by chunking the context and recursively calling a sub-model on each piece.

**Self-Verification:**
Before producing a final result, the model often uses sub-LM calls with small, focused contexts to verify its own answers.

**Constructing Long Answers:**
The model can produce outputs "well beyond the limit of the base LM." It does this by using variables in the REPL environment to store results of sub-problems and then programmatically stitching them together into a comprehensive final answer.

## The Bottom Line: A New Axis of Scale

Recursive Language Models offer a new paradigm for scaling AI. Instead of just building bigger models with larger context windows, RLMs make existing models **smarter** about how they process information. The focus shifts from brute-force memory to intelligent, procedural reasoning.

This research suggests a future where LLMs are trained not just on data, but on the **process of reasoning itself**. If a model can be taught to be its own researcher, what other complex human tasks could it learn to decompose and solve on its own?

The question that remains: if you could give a model the ability to analyze an entire codebase, a complete research corpus, or years of a company's historical data - what would you build?

---

**Reference:** This article was based on the paper ["Recursive Language Models"](https://arxiv.org/html/2512.24601v1) available on arXiv.

---

**Interested in applied AI and software engineering?** Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).

Happy building!
