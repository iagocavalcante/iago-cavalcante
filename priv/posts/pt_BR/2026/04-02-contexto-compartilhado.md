%{
  title: "Contexto Compartilhado: O que RFCs Assumem e Agentes Precisam Ouvir",
  author: "Iago Cavalcante",
  tags: ~w(ia engenharia-de-software rfcs prompts agentes desenvolvimento),
  description: "RFCs assumem que o leitor conhece o projeto. Agentes não conhecem nada. Externalizar o contexto implícito é a diferença entre código perfeito na arquitetura errada e código que realmente se encaixa.",
  locale: "pt_BR",
  published: false,
  scheduled_for: ~D[2026-04-02]
}
---

Fala, galera! Hoje começo com uma história que já vi acontecer mais de uma vez -- e que talvez você reconheça.

**O código estava perfeito. A arquitetura estava errada.**

Um desenvolvedor pediu para um agente criar um módulo de processamento de pedidos. O prompt era claro: "Crie um serviço de processamento de pedidos com validação, cálculo de preço e notificação ao cliente." O agente entregou código limpo. Testes passando. Nomes bem escolhidos. Boas práticas seguidas à risca.

Só que o projeto inteiro usava event sourcing. E o agente construiu um CRUD clássico com chamadas síncronas, atualizações diretas no banco, e estado mutável. Código impecável. Paradigma completamente errado.

O problema não foi falta de habilidade do agente. Foi falta de contexto.

## O contexto que ninguém escreve

Em qualquer equipe de engenharia que trabalha junta há algum tempo, existe uma camada invisível de conhecimento compartilhado. Quando alguém do time escreve um RFC dizendo "use nosso tratamento de erros padrão," todo mundo entende o que isso significa. Ninguém precisa explicar que "tratamento de erros padrão" significa tagged tuples `{:ok, result} | {:error, reason}`, log via Logger, retorno 4xx pra erros do cliente e 5xx pra erros do servidor.

Quando o RFC diz "siga o padrão do módulo de pagamentos," o time sabe que isso quer dizer: contexto separado, changeset de criação distinto do de atualização, referências entre contextos via campo ID simples em vez de `belongs_to`. Ninguém precisa soletrar isso. Todo mundo estava na reunião. Todo mundo leu o pull request. Todo mundo respira esse código há meses.

Esse conhecimento compartilhado é o que faz RFCs funcionarem tão bem dentro de times. Eles podem ser concisos justamente porque o leitor já carrega uma tonelada de contexto implícito.

O problema? Agentes não estavam na reunião. Não leram o pull request. Não respiram o código há meses. Eles têm **zero contexto compartilhado.**

## As cinco categorias do contexto invisível

Ao longo de vários projetos com agentes, identifiquei cinco categorias de contexto que times assumem como óbvias mas que agentes precisam ouvir explicitamente.

### 1. Stack tecnológica e bibliotecas

Parece básico, mas não é. "Crie uma API" pode resultar em Express, FastAPI, Phoenix, Spring Boot, ou qualquer outro framework. O agente vai escolher o que parecer mais provável dado o prompt -- e pode errar feio.

Não basta dizer a linguagem. Diga o framework, as bibliotecas principais, e a versão relevante quando importar. "Elixir com Phoenix 1.7, Ecto para persistência, Oban para jobs assíncronos" é muito diferente de só "Elixir."

### 2. Convenções de nomenclatura

Seu time usa `snake_case` ou `camelCase` pra campos de API? Os módulos seguem `MyApp.Context.Entity` ou `MyApp.Entity.Context`? Os testes ficam em `test/context/entity_test.exs` ou `test/entity_test.exs`?

Essas convenções parecem triviais, mas quando o agente gera código com uma convenção diferente da do projeto, o resultado é aquela sensação de "algo está estranho" que consome tempo na revisão. O código funciona, mas não se encaixa.

### 3. Padrões arquiteturais

Essa é a categoria do exemplo da abertura. REST vs. event sourcing. Monolito vs. microserviços. MVC vs. contexts-based. Chamadas síncronas vs. mensageria. Active Record vs. Repository pattern.

Se o agente não sabe qual padrão o projeto segue, ele vai escolher o mais convencional. E "o mais convencional" nem sempre é o que o seu projeto usa. Código perfeito, paradigma errado.

### 4. Módulos e infraestrutura do projeto

Todo projeto maduro tem seus módulos internos. Sanitizers, caches, supervisors de tasks, detectores de spam, helpers de autenticação. O agente não sabe que eles existem.

Se o seu projeto tem um `TaskSupervisor` configurado e o agente usa `Task.start/1` (fire-and-forget), o código funciona mas viola uma decisão arquitetural importante. Se tem um `Sanitizer` pra null bytes e o agente não o usa num changeset, você introduziu uma vulnerabilidade.

### 5. Linguagem do domínio de negócio

"Pedido" é o mesmo que "ordem"? "Cliente" é diferente de "usuário"? "Aprovação" tem quantas etapas? "Publicado" significa visível pra todos ou só pra assinantes?

A linguagem do domínio é talvez a categoria mais sutil. O agente pode usar sinônimos que fazem sentido na linguagem comum mas criam confusão no código. Se o projeto inteiro usa "booking" e o agente gera código com "reservation," você tem um problema de consistência que se espalha rápido.

## Quando o contexto falta: anatomia de um desastre silencioso

Vamos voltar ao exemplo do processamento de pedidos e destrinchar o que aconteceu.

O prompt dizia:

```
Crie um serviço de processamento de pedidos.
Valide os dados do pedido.
Calcule o preço total com descontos.
Notifique o cliente quando o pedido for confirmado.
```

O agente entregou:

```elixir
defmodule MyApp.Orders do
  def create_order(attrs) do
    %Order{}
    |> Order.changeset(attrs)
    |> calculate_total()
    |> Repo.insert()
    |> notify_customer()
  end
end
```

Código limpo, certo? Mas o projeto usava event sourcing. O esperado era algo como:

```elixir
defmodule MyApp.Orders.CommandHandler do
  def handle(%CreateOrder{} = command) do
    order = Order.new(command.order_id)

    order
    |> Order.validate(command)
    |> Order.apply_discounts(command.discount_codes)
    |> Order.emit_event(%OrderCreated{})
  end
end
```

Percebe a diferença? Não é uma questão de qualidade de código. Os dois trechos são bem escritos. A diferença é de paradigma. O primeiro é imperativo, síncrono, com efeitos colaterais diretos. O segundo é baseado em eventos, com comandos e handlers separados. Os dois são "certos" -- mas só um deles se encaixa no projeto.

O agente não tinha como saber. Ninguém contou a ele.

## O padrão CLAUDE.md: externalizando o contexto

É aqui que entra uma ideia que eu considero fundamental pra quem trabalha com agentes de forma profissional: **externalizar o contexto implícito do time num documento persistente.**

O nome pode variar. CLAUDE.md, AGENTS.md, system-context.md, .cursorrules -- o nome importa menos que o hábito. A ideia é criar um documento que contenha tudo aquilo que o time sabe mas nunca escreveu.

Um bom documento de contexto cobre aquelas cinco categorias que mencionei:

```markdown
## Stack e Bibliotecas
- Elixir 1.16 com Phoenix 1.7
- Ecto para persistência, PostgreSQL
- Oban para jobs assíncronos
- Swoosh com Resend para emails
- Tailwind CSS com dark mode

## Convenções de Nomenclatura
- Contexts seguem MyApp.NomeDoContexto (ex: Iagocavalcante.Accounts)
- Schemas ficam dentro do contexto: Iagocavalcante.Accounts.User
- Testes em test/iagocavalcante/context_test.exs

## Padrões Arquiteturais
- Context-based architecture: lógica de negócio separada em contextos
- Referências entre contextos via campo ID simples, NÃO belongs_to
- Changesets separados por operação: create_changeset, update_changeset
- Ecto.Enum com atoms para campos de status

## Módulos do Projeto
- Iagocavalcante.Ecto.Sanitizer: sanitização de null bytes
- Iagocavalcante.TaskSupervisor: tasks assíncronos supervisionados
- Iagocavalcante.Bookmarks.Cache: cache ETS para bookmarks

## Segurança (CRÍTICO)
- Sanitizar TODA entrada de usuário contra null bytes
- Validar paths contra path traversal
- NUNCA usar Task.start/1 -- sempre Task.Supervisor.start_child
```

Quando o agente tem acesso a esse documento, ele não precisa adivinhar. Ele sabe que o projeto usa contexts separados, que referências são via ID simples, que existe um Sanitizer que precisa ser usado. O código que ele gera não é só correto -- ele se encaixa.

## O bônus que ninguém esperava

Aqui vai algo que eu não antecipei quando comecei a trabalhar com documentos de contexto: **eles ajudam humanos também.**

Pensa no onboarding de um novo membro do time. Quanto tempo leva até essa pessoa entender as convenções do projeto? Onde ficam os módulos? Quais são os padrões? O que nunca deve ser feito?

Normalmente, esse conhecimento é transmitido por osmose. Pair programming, code reviews, perguntas no Slack, e aquele clássico "ah, a gente não faz assim aqui, faz desse jeito." Funciona, mas é lento e depende da disponibilidade de quem já sabe.

Um documento de contexto bem escrito acelera esse processo drasticamente. O novo membro lê o documento e em 30 minutos tem uma visão clara das convenções, restrições e padrões do projeto. Não substitui o pair programming -- mas dá uma base que torna todas as outras interações mais produtivas.

É o mesmo princípio que o Pragmatic Engineer discute quando fala sobre como processos de RFC capturam conhecimento institucional. A documentação que você cria para alinhar agentes acaba se tornando documentação viva que alinha o time inteiro. O esforço de externalizar contexto para máquinas te obriga a articular coisas que sempre foram implícitas -- e essa articulação beneficia todo mundo.

## Como começar: três passos práticos

Se a ideia faz sentido mas parece trabalhoso, aqui vai um caminho incremental:

**Passo 1: Comece com o que dói.** Qual foi a última vez que um agente gerou código que "funcionava mas estava errado"? Anote o que faltou. Stack? Padrão? Convenção? Comece documentando isso.

**Passo 2: Evolua com os erros.** Cada vez que o agente erra por falta de contexto, adicione a informação que faltou ao documento. Em poucas semanas, você vai ter um documento robusto construído a partir de problemas reais.

**Passo 3: Revise com o time.** Compartilhe o documento. Pergunte: "faltou algo?" Colegas vão apontar contextos que você nem percebia que eram implícitos. Esse exercício de externalização coletiva é valioso por si só.

O documento nunca fica "pronto." Ele evolui com o projeto. E tudo bem -- o ponto não é perfeição, é ter um lugar onde o contexto vive explicitamente em vez de só na cabeça das pessoas.

## O que vem por aí

Agora temos todas as peças: estrutura de RFC, restrições explícitas, interfaces, critérios de aceite, feedback loops, e contexto compartilhado. No próximo artigo, vamos juntar tudo. Vamos falar sobre **o documento único** -- como combinar a disciplina do RFC com a flexibilidade do prompt num artefato que serve tanto para alinhar o time quanto para instruir agentes.

---

### Série: RFCs como Prompts para Desenvolvimento com Agentes de IA

1. [A conexão fundamental](/blog/o-rfc-que-ninguem-leu-e-o-prompt-que-ninguem-escreveu)
2. [Anatomia de um bom RFC](/blog/anatomia-de-um-bom-rfc)
3. [Anatomia de um bom prompt de sistema](/blog/anatomia-de-um-bom-prompt-de-sistema)
4. [Restrições explícitas — O poder do "não faça"](/blog/restricoes-explicitas-o-poder-do-nao-faca)
5. [Interfaces e contratos](/blog/interfaces-e-contratos)
6. [Critérios de aceite](/blog/criterios-de-aceite)
7. [Loops de feedback](/blog/onde-o-prompt-vai-alem-do-rfc)
8. **Contexto compartilhado** *(este artigo)*
9. O documento único *(em breve)*
10. O futuro da especificação *(em breve)*

---

Curtiu? Quer trocar ideia sobre como externalizar contexto nos seus projetos? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
