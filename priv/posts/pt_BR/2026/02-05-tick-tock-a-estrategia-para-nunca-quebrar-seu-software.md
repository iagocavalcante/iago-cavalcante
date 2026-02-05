%{
  title: "Tick-Tock: A Estratégia Para Nunca Quebrar Seu Software",
  author: "Iago Cavalcante",
  tags: ~w(software engenharia estrategia tick-tock fintech retrocompatibilidade banco-de-dados),
  description: "Como a estratégia Tick-Tock, que aprendi trabalhando na Woovi, garante que você evolua seu software sem quebrar nada. Aplicada em mudanças de banco, evolução de features e APIs.",
  locale: "pt_BR",
  published: true
}
---

Fala, pessoal! Hoje eu quero compartilhar uma estratégia que mudou completamente a forma como eu penso sobre evolução de software. Aprendi isso na prática enquanto trabalho na [Woovi](https://woovi.com), uma fintech brasileira de pagamentos Pix, e desde então virou uma das minhas ferramentas mentais mais valiosas.

Estou falando da **estratégia Tick-Tock**.

## O Problema: Feature Atrás de Feature

Vamos imaginar que você trabalha num produto que cresce rápido. Todo sprint tem feature nova, toda semana tem mudança no banco, toda release tem API nova. Parece produtivo, certo?

Errado. O que acontece na prática é:

- O banco de dados vira um frankenstein de migrations
- APIs antigas quebram sem aviso
- Clientes que integram com você ficam com medo de atualizar
- O time acumula débito técnico até não aguentar mais
- Alguém faz um deploy na sexta e quebra tudo

Sabe aquela sensação de estar correndo num trem enquanto troca as rodas? Então.

## O Que é Tick-Tock?

A estratégia Tick-Tock veio originalmente da Intel, que usava esse modelo pra evoluir processadores. A ideia é simples: **alternar entre dois tipos de ciclo**.

**Tick (Estabilização)**
- Foco em manutenção, correções e refatoração
- Zero mudanças em APIs públicas
- Melhorias de performance e código
- Pagamento de débito técnico
- O cliente não precisa mudar nada do lado dele

**Tock (Inovação)**
- Features novas, APIs novas
- Evolução de produto
- Mudanças que podem exigir adaptação do cliente
- Experimentação controlada

A sacada é: **nunca dois tocks seguidos**. Sempre que você lança algo novo (tock), o próximo ciclo é de estabilização (tick). Sempre.

## Como a Woovi Aplica Isso

Na Woovi, a gente lida com dinheiro. Literalmente. Pagamentos Pix, integrações com múltiplos provedores bancários, webhooks em tempo real. Não dá pra quebrar nada. Um bug aqui pode significar um cliente não recebendo um pagamento.

A estratégia Tick-Tock aparece em vários níveis:

### Mudanças no Banco de Dados

Essa é talvez a aplicação mais importante. Quando você trabalha com banco de dados em produção, a regra de ouro é: **nunca faça uma migration destrutiva de cara**.

Vamos imaginar que você precisa renomear um campo de `pixKey` para `dictKey`. O jeito errado:

```
// Tock direto (vai quebrar)
Migration 1: Renomeia pixKey → dictKey
// Tudo que dependia de pixKey quebra instantaneamente
```

O jeito Tick-Tock:

```
// Tock: Adiciona o novo campo
Migration 1: Adiciona campo dictKey
Migration 2: Script que copia pixKey → dictKey

// Tick: Estabiliza
Migration 3: Código passa a ler de dictKey (com fallback pra pixKey)
Testes confirmam que tudo funciona com ambos os campos

// Tock: Evolui
Migration 4: Código usa apenas dictKey
Migration 5: Remove pixKey (só depois de confirmar que ninguém usa)
```

Percebe? Cada passo é seguro. Se algo der errado em qualquer etapa, você consegue voltar atrás sem perder dados.

### Evolução de Features

Quando a gente precisa mudar o comportamento de uma feature, nunca é "troca e pronto". É sempre:

1. **Tock**: Lança a versão nova lado a lado com a antiga
2. **Tick**: Monitora, corrige bugs, garante que clientes migraram
3. **Tock**: Remove a versão antiga (se tiver certeza que ninguém usa)

Na prática, isso significa que o sistema suporta **duas versões ao mesmo tempo** por um período. Dá mais trabalho? Sim. Mas o custo de quebrar um cliente em produção é muito maior.

### APIs e Retrocompatibilidade

Isso vale especialmente pra APIs públicas. Na Woovi, a gente mantém retrocompatibilidade como prioridade. Se você precisa mudar um endpoint:

- **Tick**: Adiciona o campo novo na resposta sem remover o antigo
- **Tock**: Documenta a depreciação, dá prazo pro cliente migrar
- **Tick**: Monitora quem ainda usa o campo antigo
- **Tock**: Remove o campo antigo (com aviso prévio)

A ideia é que o cliente **nunca acorde com a integração quebrada**. Ele tem tempo, documentação e suporte pra migrar no ritmo dele.

## Por Que Funciona

A beleza do Tick-Tock é que ele resolve vários problemas ao mesmo tempo:

**Pra engenharia:**
- Débito técnico nunca acumula demais porque tem ciclo dedicado pra isso
- Deploys são mais seguros porque nunca tem mudança grande sem estabilização depois
- O time não queima em ritmo de sprint eterno

**Pro produto:**
- Features novas têm tempo pra ser polidas antes do próximo lançamento
- Feedback dos usuários é incorporado nos ciclos de tick
- Qualidade percebida do produto sobe

**Pro cliente:**
- Atualizações nunca quebram a integração
- Clientes conservadores podem ficar nos ticks e pular os tocks
- Documentação e migração são parte do processo, não um afterthought

## Aplicando no Seu Projeto

Você não precisa trabalhar numa fintech pra usar Tick-Tock. A estratégia funciona em qualquer contexto:

1. **Defina seus ciclos**: Pode ser por sprint, por mês, por release. O importante é alternar.
2. **Seja disciplinado nos ticks**: A tentação de enfiar "só mais uma feature" no ciclo de estabilização é enorme. Resista.
3. **Documente tudo**: Cada tock deve ter um plano de migração claro. Cada tick deve ter métricas de estabilidade.
4. **Comunique com clareza**: Seu time e seus clientes precisam saber em qual fase vocês estão.

## Resumindo

| | Tick | Tock |
|---|---|---|
| Foco | Estabilidade e manutenção | Features e inovação |
| APIs | Sem mudanças | Pode adicionar/mudar |
| Banco | Migrations de compatibilidade | Migrations de evolução |
| Risco | Baixo | Controlado |
| Cliente | Não precisa fazer nada | Pode precisar adaptar |

A estratégia Tick-Tock não é sobre ir devagar. É sobre ir **consistentemente rápido** sem deixar um rastro de destruição. Na Woovi, isso é o que nos permite evoluir um sistema financeiro crítico sem nunca quebrar a experiência dos nossos clientes.

É isso, pessoal! Se você quer trocar uma ideia sobre como aplicar essa estratégia no seu contexto, me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
