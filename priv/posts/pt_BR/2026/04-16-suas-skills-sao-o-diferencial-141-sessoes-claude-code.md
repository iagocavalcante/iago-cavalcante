%{
  title: "Suas Skills São o Diferencial: 141 Sessões de Claude Code, 611 Commits e o Que Realmente Importa",
  author: "Iago Cavalcante",
  tags: ~w(ai claude coding produtividade agentes skills agentic-code),
  description: "Depois de 30 dias e 141 sessões de Claude Code, os dados são claros: skills personalizadas são o que separa vibe coding de entregar produto de verdade. Os números que provam isso.",
  locale: "pt_BR",
  published: true
}
---

Fala, pessoal! Uns meses atrás eu escrevi sobre [Vibe Coding com Esteroides](/blog/vibe-coding-com-esteroides-claude-code-agentes-superpoderes) — a ideia era que skills personalizadas, agentes paralelos e superpoderes transformam o Claude Code numa máquina de produtividade.

Aquilo era teoria. Hoje eu tenho os recibos.

Rodei o comando `/insights` do Claude Code e os números dos últimos 30 dias são outro nível:

- **141 sessões analisadas**
- **611 commits**
- **96% de taxa de objetivo alcançado**
- **952 TaskUpdates, 506 invocações de agentes**

Isso é orquestração focada em entregar, em escala. E a coisa que tá puxando esses números não é o modelo. São as skills.

## A Conexão com o Livro Agentic Coding

Recentemente ajudei a revisar um livro chamado [*Agentic Coding: Claude Code for Developers*](https://www.amazon.com/Agentic-Coding-Claude-Code-Developers/dp/1806022591) — e uma das ideias centrais ficou gravada: **agentes não são mágica, são sistemas disciplinados**. A mágica acontece quando você dá o contexto certo, o processo certo e os limites certos.

É literalmente o que skills personalizadas fazem. Não são só prompts — são expertise destilada que sobrevive entre sessões. Você ensina o Claude uma vez, ele lembra pra sempre.

O que me leva à tese desse post:

> **Suas skills são o diferencial. O modelo é commodity.**

Todo mundo tem acesso ao mesmo Claude. O que separa um workflow 10x de um frustrante são as skills que você construiu em volta dele.

## 3 Skills Que Valeram Ouro

Deixa eu te mostrar como isso funciona na prática.

### 1. `write-like-iago` — Consistência de voz

Eu escrevo posts de blog, LinkedIn, rascunhos pro Reddit e roteiros de UGC. Sem uma skill, toda sessão começa do zero — "escreve com minha voz" não significa nada sem exemplos.

```markdown
---
name: write-like-iago
description: Use ao criar conteúdo para Iago Cavalcante
---

## Tom
- Conversacional e acolhedor
- Didático sem ser condescendente
- Começa com "Fala, pessoal!" ou "Hey folks!"

## Ancora em cenários reais
RUIM: "Hot reload melhora a produtividade"
BOM: "Sabe quando você criava uma skill e tinha que reiniciar a sessão?"
```

Resultado: 20+ artigos entregues esse trimestre, voz consistente em PT-BR e EN.

### 2. `elixir-skills` — O roteador que me salva de mim mesmo

Essa aqui é discretamente boa. É uma skill que *roteia pra outras skills* antes do Claude explorar o código:

```
Tarefa Elixir/Phoenix/OTP → Invocar skill PRIMEIRO → Depois explorar → Depois codar
```

Por quê? Porque skills te dizem *o que procurar*. Sem elas, o Claude explora no escuro e frequentemente adiciona um GenServer quando uma função pura resolvia. O roteador pega isso cedo.

### 3. `lovable-web-development` — Design tokens ou nada

```
Red flag: text-white  → Faça: text-foreground
Red flag: bg-black    → Faça: bg-background
Red flag: hex inline  → Faça: CSS variables com HSL
```

Construí o design inteiro da fintech Respira — landing page mais 10 telas mobile — sem uma cor hardcoded sequer. O eu do futuro consegue re-skinar tudo em 20 minutos.

## A Fricção (Pra Não Romantizar)

O relatório também apontou onde eu ainda bati a cara:

- **Renomeação com sed corrompeu uma classe silenciosamente** (`SystemPromptBuilder` → `SystemAgentBuilder`). Lição: sempre casar renomeações em massa com `tsc --noEmit`.
- **Limite de token cortou 3+ sessões de debug.** Fix: jogar os findings em `.claude/scratch/` em vez de inline.
- **Pre-push hook amendou formatação no commit errado.** Recuperação com force-push não é divertida.

Nada disso é culpa da IA. É skill faltando. Cada ponto de fricção é uma skill esperando pra ser escrita.

## O Que Tô Codificando Agora

Baseado no relatório, isso aqui vai pra minha pasta `~/.claude/skills/` essa semana:

1. **`/pr-review`** — Busca comentários do Gemini, classifica válido/inválido, aplica fixes, resolve threads, commita, pusha. Faço isso 5+ vezes por semana na mão.
2. **`/ota-release`** — Bump de versão, commit, `eas update --platform ios` e depois `--platform android` separados (nunca `--platform all`, porque web não tá configurado).
3. **Pre-commit hook** — Roda prettier e `eslint --fix` automaticamente nos arquivos TS editados. Mata o ciclo de force-push recovery.

Skills pequenas, alavancagem grande.

## Como Começar

Você não precisa de 141 sessões de dado pra começar a construir skills. Precisa de um workflow repetitivo e doloroso.

1. Percebeu que tá fazendo a mesma coisa duas vezes → **candidato a skill**
2. Escreve um markdown de 20 linhas em `~/.claude/skills/sua-skill/SKILL.md`
3. Adiciona o frontmatter com `name` e `description`
4. Usa três vezes. Refina. Entrega.

O campo `description` é a parte mais importante — o Claude usa ele pra decidir quando invocar a skill. Sê específico no gatilho.

## O Insight de Verdade

Depois de um mês de dados, isso é o que eu acredito agora:

**Desenvolvimento agêntico não é sobre o modelo ficar mais inteligente. É sobre você ficar melhor em ensiná-lo.**

A taxa de 96% de objetivo alcançado não é porque o Claude é mágico. É porque toda semana eu tô alimentando ele com uma versão mais afiada dos meus padrões, preferências e restrições. A pasta de skills é juros compostos.

Vibe coding com esteroides te faz começar. Skills são o que fazem ficar.

---

**Tem um workflow doloroso que se repete?** Essa é sua próxima skill.

Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante) — curioso pra saber o que vocês tão codificando.

Bora codar!
