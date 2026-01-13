%{
  title: "Vibe Coding com Esteroides: Claude Code, Agentes e Skills com Superpoderes",
  author: "Iago Cavalcante",
  tags: ~w(ai claude coding produtividade agentes skills automacao),
  description: "Descubra como transformar seu fluxo de desenvolvimento usando recursos avançados do Claude Code como skills personalizadas, agentes paralelos e superpoderes que transformam vibe coding em uma máquina de produtividade.",
  locale: "pt_BR",
  published: true
}
---

# Vibe Coding com Esteroides: Claude Code, Agentes e Skills com Superpoderes

Fala, pessoal! Deixa eu contar sobre algo que mudou completamente a forma como eu codifico. Você provavelmente já ouviu falar de "vibe coding" - aquele estado de fluxo onde você só descreve o que quer e a IA te ajuda a construir. Mas e se eu te dissesse que existe uma forma de turbinar essa experiência?

Estou falando do Claude Code com skills personalizadas, agentes paralelos e o que eu gosto de chamar de "superpoderes". Não é mais só vibe coding - é vibe coding com esteroides.

## O Problema com IA Básica para Código

A real é a seguinte: a maioria das pessoas usa assistentes de IA para código da forma mais básica possível. Você pergunta, recebe uma resposta, copia e cola, repete. Funciona, mas você está deixando muita coisa na mesa.

O poder de verdade vem quando você:
- Ensina a IA seus padrões e preferências
- Deixa ela rodar múltiplas tarefas em paralelo
- Cria skills reutilizáveis que codificam sua expertise
- Dá o contexto que ela precisa pra entender seu codebase de verdade

## Configurando seu Ambiente Claude Code

Primeira coisa - você precisa de um arquivo `CLAUDE.md` na raiz do seu projeto. Isso não é só documentação; é o cérebro da IA pro seu projeto:

```markdown
# CLAUDE.md

## Comandos
- **Desenvolvimento**: `mix phx.server` - Inicia em localhost:4000
- **Testes**: `mix test` - Roda a suíte de testes
- **Deploy**: `mix assets.deploy` - Build do frontend

## Arquitetura
- Phoenix LiveView para UI em tempo real
- Contexts do Ecto para lógica de negócio
- Tailwind CSS para estilização

## Padrões que Seguimos
- Sempre usar streams para listas grandes
- Preload de associações no context, não nos controllers
- Tratamento de erros via tagged tuples
```

Só esse arquivo já transforma como o Claude interage com seu código. Ele para de adivinhar e começa a saber.

## Criando Skills Personalizadas: Seu Playbook de IA Pessoal

Aqui é onde as coisas ficam interessantes. Skills são prompts reutilizáveis que codificam expertise específica. Eu tenho uma chamada `write-like-iago` que garante que todo meu conteúdo combine com minha voz:

```markdown
---
name: write-like-iago
description: Use ao criar conteúdo para Iago Cavalcante
---

# Write Like Iago

## Princípios de Estilo
- Conversacional e acolhedor
- Didático sem ser condescendente
- Começar com saudação casual: "Fala, pessoal!"
- Ancorar conceitos em cenários práticos
```

Outra que eu uso é `lovable-web-development` pra trabalho de frontend:

```markdown
---
name: lovable-web-development
description: Abordagem design-system-first para apps web bonitos
---

# Lovable Web Development

## Filosofia Central
Design tokens ANTES de componentes. Cores semânticas ANTES de features.

## Red Flags - PARE
| Prática Ruim | Faça Isso |
|--------------|-----------|
| `text-white` | `text-foreground` |
| `bg-black` | `bg-background` |
| Cores hex inline | CSS variables com HSL |
```

Essas skills ficam em `~/.claude/skills/nome-da-skill/skill.md` e o Claude carrega automaticamente quando relevante.

## Superpoderes: As Skills Built-in que Mudam Tudo

O Claude Code vem com skills poderosas built-in chamadas "superpowers". São game-changers:

### Test-Driven Development (`/test-driven-development`)

Invoque isso ANTES de escrever qualquer código de implementação. Força o ciclo red-green-refactor:

```
1. Escrever teste falhando primeiro
2. Implementar código mínimo pra passar
3. Refatorar com confiança
```

### Brainstorming (`/brainstorming`)

Use antes de qualquer trabalho criativo. Explora requisitos e design ANTES da implementação. Chega de construir a coisa errada.

### Agentes Paralelos (`/dispatching-parallel-agents`)

Aqui as coisas ficam malucas. Quando você tem múltiplas tarefas independentes, o Claude pode disparar agentes paralelos:

```
Usuário: "Corrige o bug de login E adiciona a nova feature de export"

Claude: *Dispara dois agentes em paralelo*
- Agente 1: Investigando e corrigindo bug de login
- Agente 2: Implementando feature de export
```

Ambos rodam simultaneamente. Você recebe resultados na metade do tempo.

### Code Review (`/requesting-code-review`)

Depois de completar o trabalho, invoque isso pra uma revisão completa contra seus requisitos. Pega coisas que você deixaria passar.

## Exemplo de Workflow Real

Deixa eu mostrar como isso funciona na prática. Estou construindo uma nova feature:

```
Eu: /brainstorming - Quero adicionar notificações em tempo real no meu app

Claude: *Explora requisitos*
- O que dispara notificações?
- Devem persistir ou ser efêmeras?
- Precisamos de push notifications ou só in-app?
*Apresenta opções com trade-offs*

Eu: Só in-app, efêmeras, disparadas por ações do usuário

Eu: /writing-plans - Cria o plano de implementação

Claude: *Cria plano detalhado*
1. Criar context de Notification com store em memória
2. Adicionar PubSub pra broadcasting
3. Construir componente LiveView pra exibição
4. Adicionar triggers de notificação nos eventos relevantes

Eu: /executing-plans

Claude: *Trabalha no plano sistematicamente*
*Marca itens como completos conforme termina*
*Pede revisão em checkpoints chave*
```

O processo todo é estruturado, rastreável, e produz código melhor do que só ir fazendo.

## Configurando Hooks pra Automação

O Claude Code suporta hooks - comandos shell que rodam em resposta a eventos. Adicione isso nas suas configurações:

```json
{
  "hooks": {
    "PreCommit": "mix format && mix test",
    "PostFileWrite": "mix compile --warnings-as-errors"
  }
}
```

Agora todo save de arquivo dispara compilação, e toda tentativa de commit roda testes. O Claude adapta seu comportamento baseado no feedback dos hooks.

## A Diferença Agêntica

IA tradicional pra código: Você pergunta, ela responde, você implementa.

IA agêntica pra código: Você descreve o objetivo, ela explora, planeja, implementa, testa e itera - tudo mantendo você informado.

As features chave que fazem isso funcionar:

1. **TodoWrite**: Claude rastreia seu próprio progresso em tarefas complexas
2. **Task tool**: Dispara sub-agentes especializados pra diferentes trabalhos
3. **Read/Edit/Write**: Acesso total ao sistema de arquivos com diffing inteligente
4. **WebSearch/WebFetch**: Acesso em tempo real a documentação e exemplos

## Começando Hoje

1. **Instale o Claude Code**: Siga a documentação oficial
2. **Crie seu CLAUDE.md**: Documente os comandos e padrões do seu projeto
3. **Construa uma skill personalizada**: Comece com algo que você faz repetidamente
4. **Use os superpoderes**: Experimente `/brainstorming` na sua próxima feature
5. **Experimente com agentes**: Peça pro Claude fazer duas tarefas independentes

## O Ganho Real de Produtividade

A maior mudança não é velocidade (embora seja legal). É carga cognitiva. Quando o Claude cuida do boilerplate, lembra dos padrões e pega os erros - você consegue focar nos problemas interessantes.

É como ter um desenvolvedor júnior que:
- Nunca esquece seus padrões de código
- Trabalha 24/7 sem cansar
- Aprende suas preferências ao longo do tempo
- Consegue rodar múltiplas tarefas em paralelo

Isso é vibe coding com esteroides.

---

**Pronto pra testar?** Comece com um arquivo `CLAUDE.md` simples no seu projeto e vá evoluindo. A curva de aprendizado é mais suave do que você imagina.

Tem dúvidas ou quer compartilhar sua configuração? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).

## Referências & Recursos

Quer se aprofundar mais? Aqui vão alguns recursos valiosos:

- **[Awesome Claude Code Subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)** - Lista curada de agentes que você pode usar com Claude Code
- **[System Prompts Collection](https://github.com/x1xhlol/system-prompts-and-models-of-ai-tools)** - Prompts vazados que podem inspirar a criação de agentes customizados
- **[Official Claude Plugins](https://github.com/anthropics/claude-plugins-official)** - Plugins oficiais da Anthropic
- **[Superpowers](https://github.com/obra/superpowers)** - As skills de superpoderes que transformam seu fluxo de trabalho com Claude Code

É isso, pessoal! Bora codar!
