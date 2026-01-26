%{
  title: "Como Rodar LLMs Localmente no Seu Computador Velho (Sim, É Possível)",
  author: "Iago Cavalcante",
  tags: ~w(ia llm ollama local privacidade estudantes),
  description: "Você não precisa de uma GPU de 5 mil reais pra rodar IA localmente. Com as ferramentas certas e modelos pequenos, dá pra ter um assistente de código rodando no seu notebook de faculdade.",
  locale: "pt_BR",
  published: true
}
---

Fala, pessoal! Se você é estudante ou junior e acha que rodar LLMs localmente é coisa de quem tem uma RTX 4090, tenho boas notícias: não é.

A verdade é que a comunidade open source avançou muito nos últimos meses. Hoje existem modelos pequenos, otimizados e quantizados que rodam em CPU pura—sim, aquele notebook de 8GB de RAM que você usa pra faculdade.

Nesse artigo, vou mostrar como configurar tudo do zero, quais modelos escolher pro seu hardware, e como ter um assistente de código 100% local e privado.

## Por Que Rodar Local?

Antes de meter a mão na massa, vale entender os benefícios:

1. **Privacidade total** — Seu código nunca sai da sua máquina
2. **Sem custos recorrentes** — Nada de API, tokens, ou surpresas na fatura
3. **Funciona offline** — Perfeito pra quem tem internet instável
4. **Aprendizado** — Você entende como LLMs funcionam de verdade

## O Que Você Vai Precisar

Calma, não precisa de nada absurdo:

| Hardware | Mínimo | Recomendado |
|----------|--------|-------------|
| RAM | 4GB | 8GB+ |
| Armazenamento | 5GB livre | 20GB+ |
| CPU | Qualquer x64 | Multi-core recente |
| GPU | Não precisa | Qualquer (ajuda, mas não é obrigatório) |

Se seu computador liga e roda VS Code, provavelmente roda um LLM pequeno.

## Passo 1: Instalando o Ollama

O [Ollama](https://ollama.ai) é a forma mais simples de rodar LLMs localmente. Ele cuida de tudo: download dos modelos, quantização, e interface de chat.

**No macOS/Linux:**

```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**No Windows:**

Baixe o instalador em [ollama.ai](https://ollama.ai) e siga o wizard.

Pra verificar se instalou certo:

```bash
ollama --version
```

## Passo 2: Escolhendo o Modelo Certo Pro Seu Hardware

Aqui tá o segredo. Não adianta baixar o modelo mais hypado se ele vai travar seu computador.

### Se Você Tem 4GB de RAM (Computador Bem Básico)

```bash
ollama run gemma:2b
```

O Gemma 2B da Google pesa ~1.4GB e funciona surpreendentemente bem pra tarefas simples.

### Se Você Tem 8GB de RAM (Notebook Médio)

```bash
ollama run phi3:mini
```

O Phi-3 Mini da Microsoft tem 3.8B parâmetros em apenas ~2.3GB. Excelente pra código.

Outra opção:

```bash
ollama run llama3.2:3b
```

O Llama 3.2 3B da Meta é ótimo pra uso geral.

### Se Você Tem 16GB+ de RAM

```bash
ollama run codellama:7b
```

Agora sim você pode rodar modelos maiores focados em código.

## Passo 3: Testando Seu Modelo

Depois de baixar, é só rodar:

```bash
ollama run phi3:mini
```

Vai abrir um chat no terminal. Testa algo simples:

```
>>> Explique recursão em Python com um exemplo
```

Se respondeu, parabéns! Você tem um LLM rodando local.

## Passo 4: Integrando com Seu Editor

O chat no terminal é legal, mas o poder de verdade tá na integração com seu fluxo de trabalho.

### VS Code com Continue

1. Instala a extensão [Continue](https://continue.dev)
2. Configura pra usar Ollama local
3. Seleciona o modelo que você baixou

Agora você tem autocomplete e chat de IA direto no VS Code, 100% local.

### Neovim

Se você usa Neovim, o plugin [ollama.nvim](https://github.com/nomnivore/ollama.nvim) faz a integração.

## Dicas Pra Performance

Algumas coisas que fazem diferença:

1. **Fecha outros programas** — LLMs usam bastante RAM
2. **Usa modelos quantizados** — O Ollama já faz isso automaticamente
3. **Prefere modelos menores** — Um 3B rápido é melhor que um 7B travando
4. **Monitora uso de RAM** — Se passar de 90%, o modelo vai ficar lento

## Comparativo Real de Performance

Testei no meu notebook antigo (i5 8ª gen, 8GB RAM, sem GPU dedicada):

| Modelo | Tokens/segundo | Usabilidade |
|--------|----------------|-------------|
| Gemma 2B | ~15 t/s | Muito fluido |
| Phi-3 Mini | ~8 t/s | Bom |
| Llama 3.2 3B | ~6 t/s | Aceitável |
| CodeLlama 7B | ~2 t/s | Lento, mas funciona |

Pra contexto: 8 tokens/segundo já é confortável pra uso interativo.

## O Que Esperar (E O Que Não Esperar)

**Funciona bem pra:**
- Explicar código
- Gerar funções simples
- Tirar dúvidas de sintaxe
- Sugerir refatorações pequenas

**Não espere:**
- Performance igual ao GPT-4
- Contexto gigante (limite de ~4k tokens nos modelos pequenos)
- Geração de projetos inteiros

Mas olha, pra estudante aprendendo a programar? É mais que suficiente.

## Próximos Passos

Depois que você pegar o jeito:

1. **Experimente outros modelos** — `ollama list` mostra os disponíveis
2. **Crie seus próprios prompts** — Modelfiles customizam o comportamento
3. **Explore RAG local** — Adicione seus próprios documentos como contexto
4. **Contribua com a comunidade** — Compartilha suas descobertas

## O Ponto Principal

Rodar LLMs localmente não é mais privilégio de quem tem hardware caro. Com Ollama e modelos otimizados, qualquer estudante pode ter um assistente de código privado, gratuito e offline.

O segredo tá em escolher o modelo certo pro seu hardware. Começa pequeno, testa, e vai subindo conforme seu computador aguenta.

---

**Referências:**
- [Ollama - Run Large Language Models Locally](https://ollama.ai)
- [Best Local LLMs for Low-End Computers 2025](https://www.kolosal.ai/blog-detail/top-5-best-llm-models-to-run-locally-in-cpu-2025-edition)
- [Small Local LLMs Under 8GB RAM](https://apidog.com/blog/small-local-llm/)

---

**Dúvidas ou quer compartilhar sua configuração?** Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).

É isso, pessoal! Bons estudos e boas configurações!
