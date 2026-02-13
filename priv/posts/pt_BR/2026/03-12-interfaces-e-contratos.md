%{
  title: "Interfaces e Contratos: Como Agentes Respeitam Fronteiras",
  author: "Iago Cavalcante",
  tags: ~w(ia engenharia-de-software rfcs prompts agentes desenvolvimento),
  description: "Sem contratos explícitos, cada agente inventa sua própria interface. O resultado? Sistemas que funcionam sozinhos mas quebram juntos.",
  locale: "pt_BR",
  published: false,
  scheduled_for: ~D[2026-03-12]
}
---

Fala, pessoal! Hoje eu quero começar com um cenário que todo mundo que trabalha com microserviços já viveu pelo menos uma vez.

Duas equipes. Dois serviços. Um prazo apertado. Cada time trabalha no seu canto por duas semanas. No dia da integração, ligam os dois serviços e... nada funciona.

O serviço A manda o campo `user_id` como string. O serviço B espera um inteiro. O serviço A retorna erros com um campo `error_message`. O serviço B procura por `error`. O serviço A usa `/api/v1/users/:id`. O serviço B chama `/users/get`. E por aí vai.

Cada serviço funciona perfeitamente sozinho. Juntos, são incompatíveis.

Agora troca "duas equipes" por "dois prompts dados a um agente de IA" e o cenário é exatamente o mesmo.

## O problema da interface implícita

Quando dois times não definem uma interface explícita antes de começar a codar, cada um inventa a sua. E como cada time tem contextos, experiências e preferências diferentes, as interfaces inventadas raramente são compatíveis.

Com humanos, isso é inconveniente mas recuperável. Os devs sentam juntos, olham os contratos, negociam, ajustam. Leva um dia, talvez dois. Frustrante, mas factível.

Com agentes de IA, o problema é mais profundo. O agente não negocia. Ele não olha o código do outro serviço pra ver como adaptar o seu. Quando recebe um prompt dizendo "crie um serviço de usuários", ele gera a interface que acha mais provável com base no que aprendeu. E quando outro prompt pede "crie um serviço de pedidos que consome o serviço de usuários", o segundo agente inventa *a sua própria versão* de como o serviço de usuários deveria funcionar.

O resultado é o mesmo das duas equipes: dois sistemas que funcionam isolados e quebram na integração.

## Interface-first: a lição dos RFCs

Em engenharia de software, esse problema foi resolvido há décadas. A solução tem um nome simples: **contract-first design** -- ou, no mundo dos RFCs, definição de interface antes da implementação.

A ideia é direta. Antes de qualquer time escrever uma linha de código, todos concordam com o contrato. O contrato define:

- **Endpoints**: quais caminhos existem e o que cada um faz
- **Tipos de entrada**: o que cada endpoint recebe, com tipos exatos
- **Tipos de saída**: o que cada endpoint retorna, em caso de sucesso e de erro
- **Códigos de status**: quais respostas HTTP (ou equivalentes) cada cenário produz
- **Formato de erros**: como erros são representados

Quando o contrato existe antes do código, cada time pode implementar livremente por dentro. Pode mudar a arquitetura interna, trocar o banco de dados, refatorar tudo -- desde que o contrato continue sendo respeitado. A interface é a fronteira. Dentro dela, liberdade total. Fora dela, responsabilidade compartilhada.

Esse princípio é tão fundamental que aparece em praticamente todo RFC bem escrito. A seção de "interfaces" ou "API specification" quase sempre vem antes da seção de implementação.

## O mesmo princípio, aplicado a agentes

Quando você pede a um agente de IA para criar um serviço, o prompt é o seu RFC. E se o RFC não define interfaces, o agente improvisa.

Vamos ver isso na prática com um exemplo concreto.

**Time A -- prompt sem contrato:**

```
Crie um serviço de usuários em Elixir/Phoenix que permita
criar, buscar e atualizar usuários. Use JSON para comunicação.
```

**Time B -- prompt sem contrato:**

```
Crie um serviço de pedidos em Elixir/Phoenix que crie pedidos
para usuários existentes. Consulte o serviço de usuários
para validar que o usuário existe antes de criar o pedido.
```

O que acontece?

O agente do Time A pode retornar usuários assim:

```json
{
  "user": {
    "id": "usr_abc123",
    "full_name": "Maria Silva",
    "email": "maria@example.com",
    "created_at": "2026-03-12T10:00:00Z"
  }
}
```

E o agente do Time B pode gerar código que espera isso:

```json
{
  "data": {
    "user_id": 42,
    "name": "Maria Silva",
    "email": "maria@example.com"
  }
}
```

O campo `id` virou `user_id`. O tipo mudou de string pra inteiro. O wrapper mudou de `user` pra `data`. O campo `full_name` virou `name`. Nenhuma dessas decisões está "errada" isoladamente -- são escolhas válidas. Mas juntas, são incompatíveis.

## O contrato como fundação do prompt

A solução é a mesma nos dois mundos: definir o contrato primeiro. Só que no mundo dos agentes, o contrato precisa estar **dentro do prompt**.

Veja como o mesmo cenário funciona quando você inclui o contrato:

**Contrato compartilhado (incluído em ambos os prompts):**

```
## Contrato da API de Usuários

### GET /api/v1/users/:id
Resposta de sucesso (200):
{
  "id": integer,
  "name": string,
  "email": string
}

Resposta de erro (404):
{
  "error": "not_found",
  "message": string
}

Resposta de erro (422):
{
  "error": "validation_failed",
  "details": [{"field": string, "message": string}]
}

### POST /api/v1/users
Body esperado:
{
  "name": string (obrigatório, max 100),
  "email": string (obrigatório, formato email)
}

Resposta de sucesso (201): mesmo formato do GET
```

**Time A -- prompt com contrato:**

```
Crie o serviço de usuários em Elixir/Phoenix.
Implemente os endpoints conforme o contrato abaixo.
NÃO altere os nomes de campos, tipos ou caminhos dos endpoints.

[contrato acima]
```

**Time B -- prompt com contrato:**

```
Crie o serviço de pedidos em Elixir/Phoenix.
Ao validar que o usuário existe, chame o serviço de usuários
conforme o contrato abaixo. Use exatamente os campos e tipos
definidos no contrato para parsear a resposta.

[contrato acima]
```

Agora os dois agentes trabalham com a mesma fonte de verdade. O serviço A implementa a interface exatamente como definida. O serviço B consome a interface exatamente como definida. A integração funciona na primeira tentativa.

## Type specs como contratos no Elixir

Se você trabalha com Elixir, já tem uma ferramenta poderosa pra definir contratos: **typespecs**. E elas funcionam muito bem dentro de prompts.

Em vez de descrever a interface em texto livre, você pode incluir specs que o agente vai respeitar:

```elixir
@type user :: %{
  id: integer(),
  name: String.t(),
  email: String.t()
}

@type error_response :: %{
  error: String.t(),
  message: String.t()
}

@spec get_user(integer()) :: {:ok, user()} | {:error, error_response()}
@spec create_user(map()) :: {:ok, user()} | {:error, error_response()}
```

Quando você inclui isso no prompt, está dando ao agente um contrato com a precisão de uma linguagem de programação, não a ambiguidade de uma descrição em prosa. O agente sabe exatamente que `get_user` recebe um inteiro e retorna uma tupla com um mapa de campos específicos.

É a diferença entre dizer "retorne os dados do usuário" e dizer "retorne `{:ok, %{id: integer(), name: String.t(), email: String.t()}}` ou `{:error, %{error: String.t(), message: String.t()}}`". A segunda versão não deixa espaço pra interpretação.

## O template contract-first pra prompts

Depois de aplicar esse padrão em vários projetos, cheguei num template que funciona consistentemente:

```
## Contexto
[O que o serviço faz e onde ele se encaixa no sistema]

## Contratos de Interface

### Interfaces que este serviço EXPÕE
[Endpoints, tipos de entrada, tipos de saída, códigos de erro]

### Interfaces que este serviço CONSOME
[Endpoints externos que ele chama, com formatos esperados de resposta]

## Regras de implementação
[Como o serviço deve funcionar internamente]

## Fora do escopo
[O que NÃO implementar]
```

A seção de contratos vem antes das regras de implementação. Isso é intencional. O contrato define a forma; a implementação preenche o conteúdo. O agente lê o contrato primeiro e já sabe quais são as fronteiras antes de começar a escrever código.

## Por que contratos explícitos importam mais pra agentes do que pra humanos

Um dev humano, quando encontra uma inconsistência na integração, faz o que qualquer profissional faz: investiga, pergunta, adapta. Ele abre o código do outro serviço, lê a documentação, manda uma mensagem no Slack. É um processo lento, mas funciona.

O agente não faz nada disso. Ele trabalha com o que tem no prompt. Se o prompt não tem o contrato, ele inventa. E o que ele inventa é baseado em padrões estatísticos de milhões de repositórios -- ou seja, vai ser algo razoável, mas não vai ser *o seu* contrato.

Isso significa que, paradoxalmente, contratos explícitos importam **mais** pra agentes do que pra humanos. Humanos compensam a falta de contrato com comunicação informal. Agentes não têm essa opção.

## O efeito cascata

Uma interface mal definida num prompt não quebra só um serviço. Ela quebra tudo que depende dele.

Se o agente gera um serviço de usuários com campos diferentes do esperado, o serviço de pedidos quebra. Se o serviço de pedidos está quebrado, o serviço de pagamentos que depende dele também. E se você está usando agentes pra gerar vários serviços ao mesmo tempo, cada interface implícita é uma bomba-relógio.

A abordagem contract-first evita o efeito cascata na raiz. Quando todos os contratos estão definidos antes da implementação, cada agente pode trabalhar de forma independente sem risco de incompatibilidade. É o mesmo princípio que permite que times distribuídos trabalhem em paralelo -- o contrato é o ponto de sincronização.

## O que vem por aí

No próximo artigo, vamos falar sobre **critérios de aceite** -- como definir, de forma clara e verificável, quando o trabalho do agente está completo. Se interfaces dizem como as peças se conectam, critérios de aceite dizem quando cada peça está pronta.

---

### Serie: RFCs como Prompts para Desenvolvimento com Agentes de IA

1. [A conexão fundamental](/blog/o-rfc-que-ninguem-leu-e-o-prompt-que-ninguem-escreveu)
2. [Anatomia de um bom RFC](/blog/anatomia-de-um-bom-rfc)
3. [Anatomia de um bom prompt de sistema](/blog/anatomia-de-um-bom-prompt-de-sistema)
4. [Restrições explícitas — O poder do "não faça"](/blog/restricoes-explicitas-o-poder-do-nao-faca)
5. **Interfaces e contratos — Como agentes respeitam fronteiras** *(este artigo)*
6. Critérios de aceite *(em breve)*
7. Loops de feedback *(em breve)*
8. Contexto compartilhado *(em breve)*
9. O documento único *(em breve)*
10. O futuro da especificação *(em breve)*

---

Curtiu? Quer trocar ideia sobre contratos, interfaces ou integração de serviços? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
