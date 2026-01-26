%{
  title: "How to Run LLMs Locally on Your Old Computer (Yes, It's Possible)",
  author: "Iago Cavalcante",
  tags: ~w(ai llm ollama local privacy students),
  description: "You don't need a $1,000 GPU to run AI locally. With the right tools and small models, you can have a coding assistant running on your college laptop.",
  locale: "en",
  published: true
}
---

Hey folks! If you're a student or junior dev and think running LLMs locally requires an RTX 4090, I've got good news: it doesn't.

The truth is the open source community has made massive progress in recent months. Today there are small, optimized, and quantized models that run on pure CPU—yes, that 8GB RAM laptop you use for college.

In this article, I'll show you how to set everything up from scratch, which models to choose for your hardware, and how to have a 100% local and private coding assistant.

## Why Run Local?

Before we dive in, let's understand the benefits:

1. **Total privacy** — Your code never leaves your machine
2. **No recurring costs** — No API fees, tokens, or billing surprises
3. **Works offline** — Perfect for unstable internet connections
4. **Learning** — You actually understand how LLMs work under the hood

## What You'll Need

Don't worry, nothing crazy:

| Hardware | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 4GB | 8GB+ |
| Storage | 5GB free | 20GB+ |
| CPU | Any x64 | Recent multi-core |
| GPU | Not required | Any (helps but not mandatory) |

If your computer boots and runs VS Code, it can probably run a small LLM.

## Step 1: Installing Ollama

[Ollama](https://ollama.ai) is the simplest way to run LLMs locally. It handles everything: model downloads, quantization, and chat interface.

**On macOS/Linux:**

```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**On Windows:**

Download the installer from [ollama.ai](https://ollama.ai) and follow the wizard.

To verify installation:

```bash
ollama --version
```

## Step 2: Choosing the Right Model for Your Hardware

Here's the secret. There's no point downloading the most hyped model if it's going to freeze your computer.

### If You Have 4GB RAM (Very Basic Computer)

```bash
ollama run gemma:2b
```

Google's Gemma 2B weighs ~1.4GB and works surprisingly well for simple tasks.

### If You Have 8GB RAM (Average Laptop)

```bash
ollama run phi3:mini
```

Microsoft's Phi-3 Mini has 3.8B parameters in just ~2.3GB. Excellent for code.

Another option:

```bash
ollama run llama3.2:3b
```

Meta's Llama 3.2 3B is great for general use.

### If You Have 16GB+ RAM

```bash
ollama run codellama:7b
```

Now you can run larger code-focused models.

## Step 3: Testing Your Model

After downloading, just run:

```bash
ollama run phi3:mini
```

A chat interface opens in your terminal. Test something simple:

```
>>> Explain recursion in Python with an example
```

If it responded, congrats! You have an LLM running locally.

## Step 4: Integrating with Your Editor

Terminal chat is nice, but the real power is in workflow integration.

### VS Code with Continue

1. Install the [Continue](https://continue.dev) extension
2. Configure it to use local Ollama
3. Select the model you downloaded

Now you have AI autocomplete and chat directly in VS Code, 100% local.

### Neovim

If you use Neovim, the [ollama.nvim](https://github.com/nomnivore/ollama.nvim) plugin handles integration.

## Performance Tips

A few things that make a difference:

1. **Close other programs** — LLMs use a lot of RAM
2. **Use quantized models** — Ollama does this automatically
3. **Prefer smaller models** — A fast 3B beats a laggy 7B
4. **Monitor RAM usage** — If it goes past 90%, the model will slow down

## Real-World Performance Comparison

Tested on my old laptop (i5 8th gen, 8GB RAM, no dedicated GPU):

| Model | Tokens/second | Usability |
|-------|---------------|-----------|
| Gemma 2B | ~15 t/s | Very smooth |
| Phi-3 Mini | ~8 t/s | Good |
| Llama 3.2 3B | ~6 t/s | Acceptable |
| CodeLlama 7B | ~2 t/s | Slow but works |

For context: 8 tokens/second is already comfortable for interactive use.

## What to Expect (And What Not to Expect)

**Works well for:**
- Explaining code
- Generating simple functions
- Answering syntax questions
- Suggesting small refactors

**Don't expect:**
- GPT-4 level performance
- Huge context (small models cap at ~4k tokens)
- Generating entire projects

But look, for a student learning to code? It's more than enough.

## Next Steps

Once you get the hang of it:

1. **Try other models** — `ollama list` shows available ones
2. **Create custom prompts** — Modelfiles customize behavior
3. **Explore local RAG** — Add your own documents as context
4. **Contribute to the community** — Share your findings

## The Bottom Line

Running LLMs locally is no longer a privilege for those with expensive hardware. With Ollama and optimized models, any student can have a private, free, and offline coding assistant.

The secret is choosing the right model for your hardware. Start small, test, and scale up as your computer can handle it.

---

**References:**
- [Ollama - Run Large Language Models Locally](https://ollama.ai)
- [Best Local LLMs for Low-End Computers 2025](https://www.kolosal.ai/blog-detail/top-5-best-llm-models-to-run-locally-in-cpu-2025-edition)
- [Small Local LLMs Under 8GB RAM](https://apidog.com/blog/small-local-llm/)

---

**Questions or want to share your setup?** Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iagocavalcante).

Happy building!
