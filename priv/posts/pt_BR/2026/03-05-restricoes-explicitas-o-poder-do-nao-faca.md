%{
  title: "Restrições Explícitas: O Poder do 'Não Faça'",
  author: "Iago Cavalcante",
  tags: ~w(ia engenharia-de-software rfcs prompts agentes desenvolvimento),
  description: "A seção mais subestimada de qualquer RFC é a de 'fora do escopo'. Para agentes de IA, ela é a diferença entre um resultado útil e três horas de retrabalho.",
  locale: "pt_BR",
  published: false,
  scheduled_for: ~D[2026-03-05]
}
---

Fala, galera! Hoje eu quero começar com uma história que eu garanto que vai soar familiar.

Você pede pra um agente de IA: **"Cria uma página de perfil de usuário."** Simples, direto, objetivo. Meia hora depois, você olha o resultado e descobre que recebeu um sistema completo de gerenciamento de identidade.

Tem upload de avatar com crop e resize. Tem verificação de email com reenvio automático. Tem preferências de notificação com toggles granulares. Tem histórico de alterações com diff visual. Tem até integração com Gravatar que ninguém pediu.

Você queria uma página com nome, email e bio. Recebeu um mini-SaaS.

## Por que isso acontece?

Quando um humano recebe esse mesmo pedido, a primeira reação é perguntar. "Perfil com o quê? Quais campos? O usuário pode editar? Precisa de foto? Tem alguma integração?" O dev faz essas perguntas porque tem experiência suficiente pra saber que "página de perfil" pode significar cinquenta coisas diferentes.

O agente não pergunta. Ele não tem esse instinto. Quando recebe um pedido sem fronteiras, ele preenche o vazio com o que acha mais provável — e "mais provável" pra um modelo treinado em milhões de repositórios é "tudo que já vi em páginas de perfil, junto."

Isso não é um bug. É o comportamento esperado quando você não define limites.

## A seção que ninguém valoriza

Em qualquer RFC bem escrito, existe uma seção que a maioria das pessoas pula na leitura: **Non-goals** (ou "Fora do escopo").

É a seção mais subestimada de qualquer documento de design. E, ironicamente, é a mais poderosa.

Quando você escreve "Este RFC NÃO cobre autenticação social", você está fazendo algo que parece passivo mas é ativo. Você está eliminando uma categoria inteira de decisões, implementações, discussões e bugs. Está dizendo para todo mundo envolvido: não gaste neurônios com isso agora.

Pra humanos, essa seção evita scope creep — aquele fenômeno em que o projeto vai crescendo aos poucos até virar um monstro. Pra agentes de IA, ela evita algo equivalente: **feature hallucination** — quando o agente inventa funcionalidades que ninguém pediu porque o prompt não disse pra não inventar.

## "Não faça" é mais forte que "faça"

Esse é um princípio contra-intuitivo, mas pensa comigo.

Se eu digo "crie uma página de perfil com nome, email e bio", o agente tem uma direção. Mas a tentação de adicionar "melhorias" continua lá. Ele pode pensar: "bom, se tem email, faz sentido ter verificação de email. E se tem perfil, faz sentido ter avatar." A lista de features cresce por associação.

Agora compara com isso:

```
Crie uma página de perfil de usuário.

NÃO implemente:
- Upload de avatar
- Verificação de email
- Preferências de notificação
- Integração com serviços externos
- Histórico de alterações
```

A segunda versão é cirúrgica. Ela não elimina só uma resposta errada — ela elimina categorias inteiras de respostas erradas. Cada "NÃO" é uma cerca que o agente não vai pular.

Dizer "faça X" define um caminho. Dizer "NÃO faça Y" elimina cem caminhos errados de uma vez.

## O imposto de fronteira

Eu chamo isso de **"boundary tax"** — o imposto de fronteira. É o custo que você paga quando não define limites logo de cara.

Sem restrições explícitas, o que acontece é previsível:

1. O agente entrega algo maior do que o pedido
2. Você gasta tempo avaliando o que é útil e o que é ruído
3. Você pede pra remover as partes indesejadas
4. O agente remove, mas às vezes quebra outras coisas no processo
5. Você gasta mais tempo debugando os efeitos colaterais

O tempo total desse ciclo quase sempre é maior do que o tempo que você gastaria escrevendo três linhas de restrições no prompt original. É um imposto invisível, mas real.

Compare com o cenário oposto: cinco minutos definindo o que está fora do escopo, resultado limpo na primeira tentativa. A conta fecha toda vez.

## Restrições na prática: antes e depois

Vamos ver um exemplo completo. Imagine que você está construindo um serviço de perfil de usuário numa aplicação Phoenix.

**Antes — o prompt sem fronteiras:**

```
Crie um contexto de perfil de usuário em Elixir/Phoenix com os campos
necessários e as funções CRUD.
```

O que o agente provavelmente vai entregar: schema com 15 campos, upload de avatar via S3, validações complexas de email com envio de confirmação, sistema de followers, privacy settings, e talvez até um GenServer de cache que ninguém pediu.

**Depois — o prompt com restrições explícitas:**

```
Crie um contexto de perfil de usuário em Elixir/Phoenix.

## Campos
- display_name (string, obrigatório, max 100 chars)
- bio (text, opcional, max 500 chars)
- website (string, opcional, validar formato URL)
- user_id (referência, obrigatório)

## Funcionalidades
- CRUD básico (create, read, update, delete)
- Changeset com validações dos campos acima

## Fora do escopo — NÃO implemente
- Upload ou processamento de imagens/avatar
- Verificação ou confirmação de email
- Sistema de followers ou conexões sociais
- Preferências de notificação
- Cache ou otimizações de performance
- Seeds ou dados de exemplo
- Testes (vou escrever separadamente)

## Restrições técnicas
- Usar o padrão de contextos do Phoenix
- user_id como campo simples (:id), sem belongs_to
- Sanitizar inputs contra null bytes (usar o módulo Sanitizer do projeto)
```

A diferença é brutal. O segundo prompt vai gerar exatamente o que você precisa. Sem surpresas, sem limpeza, sem retrabalho.

## Como escrever boas restrições

Depois de meses trabalhando com agentes de IA usando essa abordagem, eu criei um template mental que funciona bem:

**1. Liste o que o agente vai querer adicionar.** Pense nas features "óbvias" que um dev (ou modelo) associaria ao que você está pedindo. Se você está pedindo um formulário de contato, o agente vai querer adicionar CAPTCHA, rate limiting, templates de email, confirmação de recebimento.

**2. Seja explícito sobre cada uma.** Não basta um "mantenha simples". Diga exatamente o que não entra. "NÃO adicione CAPTCHA. NÃO implemente rate limiting. NÃO crie templates de email."

**3. Explique o porquê quando for não-óbvio.** Se a restrição parece estranha sem contexto, adicione uma justificativa curta. "NÃO use belongs_to — os contextos são independentes neste projeto." Isso evita que o agente "corrija" sua restrição achando que é um erro.

**4. Separe restrições de escopo de restrições técnicas.** "Fora do escopo" é o que não deve existir. "Restrições técnicas" é como o que existe deve ser feito. Misturar os dois confunde tanto humanos quanto agentes.

**5. Use o formato de lista.** Parágrafos longos de restrições se perdem no meio do prompt. Listas com "NÃO" em maiúsculo são impossíveis de ignorar — tanto pra quem lê quanto pra quem processa.

## O padrão: restrições como guardrails, não como limitações

Uma coisa que eu demorei pra entender é que restrições bem escritas não limitam o agente — elas **liberam** o agente.

Parece paradoxo, mas faz sentido. Quando o agente sabe exatamente o que não deve fazer, ele pode focar toda a capacidade no que deve. Sem restrições, ele gasta "energia" (tokens, atenção) decidindo se deve ou não adicionar cada feature auxiliar. Com restrições claras, essa decisão já está tomada.

É a mesma lógica dos guardrails numa estrada de montanha. Eles não existem pra limitar o motorista — existem pra ele poder dirigir com confiança, sabendo que se desviar um pouco, tem algo que impede a catástrofe.

Suas restrições são os guardrails do agente.

## O que vem por aí

No próximo artigo, vamos falar sobre **interfaces e contratos** — como definir as fronteiras entre componentes de forma que o agente respeite a arquitetura do seu sistema. Se restrições dizem o que não fazer, interfaces dizem como as peças se conectam.

---

### Série: RFCs como Prompts para Desenvolvimento com Agentes de IA

1. [A conexão fundamental](/blog/o-rfc-que-ninguem-leu-e-o-prompt-que-ninguem-escreveu)
2. Anatomia de um bom RFC *(em breve)*
3. Anatomia de um bom prompt de sistema *(em breve)*
4. **Restrições explícitas — O poder do "não faça"** *(este artigo)*
5. Interfaces e contratos *(em breve)*
6. Critérios de aceite *(em breve)*
7. Loops de feedback *(em breve)*
8. Contexto compartilhado *(em breve)*
9. O documento único *(em breve)*
10. O futuro da especificação *(em breve)*

---

Curtiu? Quer trocar ideia ou discordar de algo? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
