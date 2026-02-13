%{
  title: "Critérios de Aceite: Quando o Agente Sabe que Terminou",
  author: "Iago Cavalcante",
  tags: ~w(ia engenharia-de-software rfcs prompts agentes desenvolvimento),
  description: "Sem critérios de aceite claros, o agente não sabe quando parar. O resultado é gold-plating ou entrega incompleta - os mesmos problemas que humanos têm, amplificados.",
  locale: "pt_BR",
  published: false,
  scheduled_for: ~D[2026-03-19]
}
---

Fala, pessoal! Quando é que uma feature está pronta? Pergunta pra cinco devs e você recebe sete respostas.

Um diz que está pronta quando o código compila. Outro diz que está pronta quando tem teste. O terceiro diz que está pronta quando passou no code review. O quarto diz que está pronta quando está em produção. O quinto diz que nunca está pronta de verdade, abre uma cerveja e muda de assunto.

Agora imagina essa mesma pergunta feita a um agente de IA. Ele não tem cerveja pra abrir, não tem noção de "bom o suficiente" e, principalmente, não tem um sensor interno que diz "para, chegou." Sem esse sensor, ele faz uma de duas coisas: para cedo demais ou não para nunca.

## O problema do "pronto" sem definição

Quando um humano trabalha sem critérios de aceite claros, acontecem dois cenários clássicos.

O primeiro é **under-delivery**. O dev implementa o caminho feliz, ignora edge cases, esquece a validação de erro, e marca como concluído. Tecnicamente funciona. Na prática, quebra na primeira terça-feira de uso real.

O segundo é **gold-plating**. O dev se empolga. O login que era pra ser simples ganha autenticação biométrica. O formulário de contato ganha um chatbot. A feature vira um produto. Três semanas depois, alguém pergunta "por que gastamos tanto tempo nisso?" e a resposta é um silêncio constrangedor.

Agentes de IA têm exatamente os mesmos problemas, mas amplificados.

O under-delivery de um agente é sorrateiro. Ele entrega algo que parece completo na superfície. O código compila, os nomes das funções fazem sentido, tem até comentários. Mas quando você olha de perto, percebe que a função de deletar não verifica permissões, que o endpoint de listagem não tem paginação, que a validação de email aceita "abc@" como válido. O agente parou porque achou que tinha cumprido o pedido, e tecnicamente cumpriu -- da forma mais rasa possível.

O gold-plating de um agente é espetacular. Lembra daquele exemplo do artigo sobre restrições? Você pede uma página de perfil e recebe um sistema de identidade completo. Isso é gold-plating puro. O agente não sabe que deveria parar depois do nome, email e bio. Sem um sinal explícito de "isso é tudo que eu preciso", ele continua adicionando o que considera relevante. E um modelo treinado em milhões de repositórios considera muita coisa relevante.

## A definição de pronto que funciona

Em qualquer RFC bem escrito, existe uma seção que resolve esse problema na raiz: **critérios de aceite**.

Não confunda com requisitos. Requisitos descrevem o que construir. Critérios de aceite descrevem como saber que o que foi construído está certo. É a diferença entre "implemente login" e "o usuário consegue fazer login com email e senha, recebe erro claro quando a senha está errada, e a sessão expira após 60 dias."

Pra humanos, critérios de aceite servem como contrato entre quem pede e quem implementa. Se todos os critérios passam, a feature está pronta. Sem discussão, sem subjetividade, sem "mas eu achei que precisava de mais."

Pra agentes de IA, eles servem como **sinal de parada**. O agente sabe que terminou quando pode verificar cada item da lista e confirmar que está atendido. Sem essa lista, ele usa a própria intuição -- e a intuição de um LLM é "fazer tudo que já vi sendo feito em contextos parecidos."

## A diferença entre vago e preciso

Vamos pegar um exemplo concreto. Imagine que você está pedindo para um agente implementar o cadastro de usuários de uma aplicação.

**Critério vago:**

```
O usuário pode se cadastrar e fazer login.
```

O que o agente entrega com isso? Depende do humor do modelo naquele dia. Talvez um formulário com email e senha. Talvez um sistema com OAuth, verificação de email, recuperação de senha, 2FA, e login social. Ambas as interpretações atendem "o usuário pode se cadastrar e fazer login." O critério é tão amplo que qualquer coisa passa.

**Critério preciso:**

```
Critérios de aceite:
- Usuário pode se registrar com email e senha
- Senha tem no mínimo 8 caracteres, validação no cliente e servidor
- Email deve ser único no sistema (erro claro se já existe)
- Após registro, usuário recebe email de confirmação em até 30 segundos
- Usuário só consegue fazer login após clicar no link de confirmação
- Login com credenciais inválidas retorna "Email ou senha incorretos" (sem revelar qual)
- Sessão persiste por 60 dias de inatividade
- Logout invalida a sessão imediatamente
```

A diferença é brutal. O primeiro critério deixa o agente no escuro. O segundo acende todas as luzes. Cada item é verificável, específico e testável. O agente sabe exatamente quando parou de implementar cedo demais (se faltou algum item) e quando está indo longe demais (se está fazendo algo que nenhum item pede).

## O truque da tripla utilidade

Aqui vem a parte que conecta tudo. Leia de novo aqueles critérios precisos. Agora tenta enxergar eles de três ângulos diferentes.

**Ângulo 1 — Definição de pronto no RFC.** Cada item é um critério de aceite que o time de engenharia usa pra saber se a feature está completa. O product manager lê a lista, confere cada ponto, assina embaixo. Padrão.

**Ângulo 2 — Especificação de testes.** Cada item é um test case. "Senha tem no mínimo 8 caracteres" vira `test "rejects password with less than 8 characters"`. "Email deve ser único" vira `test "returns error when email already exists"`. A lista de critérios é, na prática, sua test suite escrita em linguagem natural.

**Ângulo 3 — Instruções do prompt.** Cada item é uma restrição para o agente. "Sessão persiste por 60 dias" diz exatamente o que configurar. "Login com credenciais inválidas retorna mensagem genérica" diz exatamente o comportamento de erro. O agente lê isso e sabe o que fazer, o que não fazer, e quando parar.

Três documentos. O mesmo texto. Isso é eficiência de comunicação.

Eu chamo isso de **padrão de tripla utilidade**: critérios de aceite escritos com precisão suficiente servem simultaneamente como definição de pronto, especificação de teste e instrução de prompt. Você escreve uma vez, usa três vezes.

## Como escrever critérios que funcionam nos três contextos

Depois de meses refinando essa abordagem, eu encontrei quatro regras que fazem a diferença.

**1. Cada critério deve ser verificável por uma pessoa sem contexto.** Se alguém que nunca viu o projeto consegue ler o critério e dizer "sim, isso funciona" ou "não, isso não funciona", o critério está bom. "A experiência do usuário deve ser boa" falha esse teste. "O formulário de registro carrega em menos de 2 segundos" passa.

**2. Use números quando possível.** "A senha deve ser forte" é subjetivo. "A senha deve ter no mínimo 8 caracteres, incluindo uma letra maiúscula e um número" é objetivo. Agentes respondem muito bem a números porque eliminam ambiguidade. Humanos também, mas costumam reclamar mais.

**3. Inclua os cenários de erro.** A maioria dos critérios de aceite só cobre o caminho feliz. Isso é um convite pra under-delivery, porque o agente (e o dev) vai focar no que dá certo e ignorar o que dá errado. "Login com credenciais inválidas retorna erro 401 com mensagem genérica" é tão importante quanto "login com credenciais válidas cria uma sessão."

**4. Separe comportamento de implementação.** O critério diz o que o sistema faz, não como ele faz. "Sessão persiste por 60 dias" é comportamento. "Usar JWT com expiração de 60 dias armazenado em cookie HttpOnly" é implementação. Critérios de aceite descrevem o quê. Restrições técnicas (que a gente viu no artigo anterior) descrevem o como.

## Critérios na prática: o antes e depois

Vamos ver isso num prompt real. Imagine que você quer um agente implementando um sistema de bookmarks.

**Antes — sem critérios de aceite:**

```
Crie um sistema de bookmarks para salvar links.
O usuário deve poder adicionar, editar e remover bookmarks.
Use Phoenix LiveView.
```

O que vai acontecer? O agente vai implementar algo. Talvez funcione, talvez não. Talvez tenha validação, talvez não. Talvez lide com URLs duplicadas, talvez não. Você vai descobrir na hora de testar, e aí começa o ciclo de correções.

**Depois — com critérios de aceite:**

```
Crie um sistema de bookmarks para salvar links.

## Critérios de aceite
- Usuário pode adicionar bookmark com URL e título (ambos obrigatórios)
- URL é validada no formato (deve começar com http:// ou https://)
- URLs duplicadas para o mesmo usuário retornam erro claro
- Título tem limite de 200 caracteres (trunca silenciosamente se maior)
- Usuário pode editar título de um bookmark existente
- Usuário pode remover bookmark com confirmação (soft delete)
- Lista de bookmarks mostra título, URL e data de criação
- Lista é ordenada por data de criação (mais recente primeiro)
- Lista tem paginação com 20 itens por página
- Usuário só vê seus próprios bookmarks (nunca os de outro usuário)

## Fora do escopo
- Tags ou categorias
- Busca ou filtros
- Importação/exportação
- Preview de links (unfurl)
- Compartilhamento
```

Com a segunda versão, o agente tem um checklist. Cada item é um comportamento verificável. Quando todos estão implementados, ele para. Se ele começar a adicionar tags ou busca, está violando o escopo. Se ele não implementar paginação, está faltando critério. O limite é claro nos dois sentidos.

## O sinal de parada que agentes precisam

Esse é o ponto mais sutil de todo o artigo. Humanos têm um mecanismo embutido de "bom o suficiente". A gente sente quando algo está pronto. Às vezes erramos pra mais, às vezes pra menos, mas tem um instinto ali.

Agentes não têm isso. Eles são otimizadores sem freio. Se o prompt diz "crie um sistema de bookmarks", eles vão otimizar para "o melhor sistema de bookmarks que eu consigo gerar" — que inclui tudo que eles sabem sobre bookmarks. E eles sabem muito.

Critérios de aceite são o freio. São o sinal de parada que o agente não tem naturalmente. São a diferença entre um agente que produz exatamente o que você precisa e um agente que produz tudo que ele sabe.

E o mais bonito: o mesmo freio funciona para humanos. A mesma lista que diz pro agente "pare aqui" diz pro dev "termine aqui" e pro QA "teste isso."

## O que vem por aí

No próximo artigo, vamos falar sobre **loops de feedback** — o ponto onde prompts vão além do que RFCs tradicionais oferecem. RFCs são documentos estáticos. Prompts podem ser dinâmicos. E quando você combina critérios de aceite com feedback iterativo, a qualidade do resultado muda de patamar.

---

### Série: RFCs como Prompts para Desenvolvimento com Agentes de IA

1. [A conexão fundamental](/blog/o-rfc-que-ninguem-leu-e-o-prompt-que-ninguem-escreveu)
2. [Anatomia de um bom RFC](/blog/anatomia-de-um-bom-rfc)
3. [Anatomia de um bom prompt de sistema](/blog/anatomia-de-um-bom-prompt-de-sistema)
4. [Restrições explícitas — O poder do "não faça"](/blog/restricoes-explicitas-o-poder-do-nao-faca)
5. Interfaces e contratos *(em breve)*
6. **Critérios de aceite — Quando o agente sabe que terminou** *(este artigo)*
7. Loops de feedback *(em breve)*
8. Contexto compartilhado *(em breve)*
9. O documento único *(em breve)*
10. O futuro da especificação *(em breve)*

---

Curtiu? Quer trocar ideia ou discordar de algo? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
