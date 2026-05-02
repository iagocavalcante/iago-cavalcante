%{
  title: "Claude Turbo Search: A Estratégia para Economizar 60% de Tokens (e Pra Onde Vou Levar Isso Depois)",
  author: "Iago Cavalcante",
  tags: ~w(ai claude coding produtividade agentes tokens search busca-semantica),
  description: "Por que eu criei o Claude Turbo Search, a estratégia de buscar antes de ler, e o plano de portar pra Codex, Antigravity e Cursor.",
  locale: "pt_BR",
  published: false
}
---

Fala, pessoal! Se você usa Claude Code num projeto de verdade, já sentiu essa dor: toda vez que abre uma sessão nova, o agente começa "explorando". Lê arquivo. Lê mais arquivo. Lê o README. Lê mais arquivo só pra ter certeza. Quando ele finalmente começa a trabalhar na sua tarefa, você já queimou um terço da janela de contexto.

Cansei de pagar esse pedágio. Então criei o [Claude Turbo Search](https://github.com/iagocavalcante/claude-turbo-search).

Esse post é sobre a estratégia por trás dele — e pra onde quero levar isso depois (spoiler: Codex, Antigravity, Cursor).

## O Problema Real Não É o Modelo

É tentador culpar o modelo. "O Claude lê demais." "O Cursor desperdiça token." "O Codex relê arquivo que já viu."

Beleza. Mas o gargalo real está antes disso: **as ferramentas agênticas leem arquivos por padrão, em vez de buscar dentro deles**.

Quando eu pergunto "onde está a autenticação nesse projeto?", a resposta preguiçosa é abrir 8 arquivos até achar. A resposta inteligente é dar um grep em `auth` primeiro, filtrar os candidatos, e aí sim ler só o que importa.

Humano faz isso natural. Agente, por padrão, não faz. Ele lê.

É essa lacuna que o Turbo Search fecha.

## A Estratégia: Busque Antes de Ler

Três primitivos, uma filosofia:

1. **Sugestão rápida de arquivos** — ripgrep + fzf pra autocomplete instantâneo. Sem precisar de LLM.
2. **Busca semântica em docs** — QMD acha arquivos por significado, não só por palavra-chave. O agente busca antes de ler.
3. **Memória persistente** — sessões não começam do zero. O que você aprendeu semana passada continua aí essa semana.

A skill `/qmd` ensina pro Claude uma única regra: **busca no índice, depois lê só o que bater**. Só isso. É essa a sacada toda.

Parece bobeira. A economia não é. Em projetos reais a gente já viu redução de 60–80% de tokens em tarefas de exploração. Não é porque o modelo ficou mais esperto — é porque o agente parou de reler o codebase como se fosse a primeira vez.

## Por Que Isso Compõe

A outra peça é a memória. A cada sessão, você roda `/remember` e o agente salva o que aprendeu — arquivos tocados, decisões tomadas, pegadinhas que descobriu. Na próxima sessão, esse contexto carrega automático.

Parece simples. O efeito é bizarro: depois de algumas semanas de trabalho, o agente conhece seu projeto melhor do que um contratado novo conheceria depois de um mês. E faz isso sem reler nada.

Junta isso com `/turbo-index` (que configura ripgrep, fzf, QMD e cartographer numa tacada só) e `/token-stats` (pra você *ver* a economia acontecendo) e o ciclo fecha.

Você não tá só economizando token. Você tá montando um sistema onde o contexto **compõe** em vez de zerar a cada sessão.

## Pra Onde Isso Vai Agora

A real é o seguinte: essa estratégia não é exclusiva do Claude.

Codex tem o mesmo problema. Antigravity tem o mesmo problema. Cursor tem o mesmo problema. Toda ferramenta agêntica de código queima token relendo arquivo que podia ter buscado.

Então os próximos capítulos do Turbo Search são sobre portabilidade:

### 1. Port pra Codex

O agente Codex da OpenAI roda num harness diferente, mas o gargalo é idêntico. O plano é entregar versões nativas de `/turbo-index`, `/qmd` e `/remember` pro Codex — mesmos primitivos, superfície de invocação diferente. O índice do QMD já é um artefato portátil, então o trabalho mesmo é na camada de skill/plugin.

### 2. Port pra Antigravity

O Antigravity do Google é interessante porque o loop do agente é mais autônomo — o que significa que desperdício de token compõe ainda mais rápido. Disciplina de busca-primeiro economiza mais lá, não menos. Quero que o Turbo Search seja instalação padrão em todo projeto Antigravity.

### 3. Port pra Cursor

Cursor é o mais complicado porque é IDE, não CLI. Mas os agentes do Cursor têm o mesmo problema de exploração, e a IDE até dá uma superfície melhor pra sugestão rápida de arquivo (o editor já sabe o estado do buffer). O plano é uma extensão Cursor que embrulha os mesmos primitivos.

## A Aposta Maior

Os modelos vão continuar ganhando janelas de contexto maiores. *Não* vão ficar mais baratos por token no mesmo ritmo. Então a disciplina de **buscar antes de ler** não vai sumir — vai importar mais, não menos.

Se eu conseguir tornar essa disciplina portátil entre Claude, Codex, Antigravity e Cursor, "agentic coding" deixa de ser "em qual modelo eu confio" e vira "qual ambiente respeita meus tokens".

É essa a aposta.

## Testa Hoje

Hoje o Claude Turbo Search funciona no Claude Code. Pra instalar:

```bash
claude plugin marketplace add iagocavalcante/claude-turbo-search
claude plugin install claude-turbo-search@claude-turbo-search-dev
```

Aí em qualquer projeto, roda `/turbo-index` uma vez. Depois disso, é só seguir trabalhando — o agente vai começar a buscar antes de ler sem você precisar lembrar ele toda hora.

Se quiser acompanhar os ports pra Codex/Antigravity/Cursor conforme saem, dá uma estrelinha no [repo no GitHub](https://github.com/iagocavalcante/claude-turbo-search) — é lá que eu corto release primeiro.

Bora testar? Me chama no [Twitter](https://x.com/iagoangelimc) ou no [LinkedIn](https://linkedin.com/in/iago-a-cavalcante) e me conta como ficou seu `/token-stats` depois de uma semana.
