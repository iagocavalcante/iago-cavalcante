%{
  title: "Anatomia de um Bom Prompt de Sistema",
  author: "Iago Cavalcante",
  tags: ~w(ia engenharia-de-software rfcs prompts agentes desenvolvimento),
  description: "Cada seção de um RFC tem um espelho exato no mundo dos prompts. Quando você enxerga o mapeamento, escrever prompts vira algo natural.",
  locale: "pt_BR",
  published: false,
  scheduled_for: ~D[2026-02-26]
}
---

Fala, galera! Na semana passada a gente dissecou o RFC. Hoje a gente coloca ele na frente do espelho.

Se o artigo anterior mostrou *por que* a estrutura de um RFC funciona, este mostra *onde* cada peça se encaixa no mundo dos prompts de sistema. E quando você enxerga o mapeamento, algo muda: escrever prompts deixa de ser adivinhação e vira engenharia.

## O espelho: RFC vs. prompt de sistema

Vamos direto ao ponto. Cada seção clássica de um RFC tem um equivalente direto num prompt de sistema:

| Elemento do RFC | Equivalente no Prompt |
|---|---|
| Problem Statement | Contexto / Definição de papel |
| Proposed Solution | Descrição da tarefa |
| Constraints | Regras / Limites |
| Non-Goals | Exclusões explícitas ("NÃO faça...") |
| Open Questions | Pedidos de esclarecimento |
| Acceptance Criteria | Formato de saída / Critérios de sucesso |

Parece simples demais? Parece. Mas a maioria dos prompts que a gente vê por aí ignora pelo menos metade dessas seções. E é exatamente aí que as coisas dão errado.

Vamos caminhar por cada linha dessa tabela com exemplos concretos.

## Problem Statement -> Contexto e papel

No RFC, o problem statement responde: "por que estamos fazendo isso?" No prompt, o contexto faz a mesma coisa. Ele ancora o agente numa realidade específica.

Sem contexto, o agente opera no vácuo. Com contexto, ele sabe *quem* é, *onde* está e *por que* foi chamado.

```
# Sem contexto (problem statement)
"Processa essas notificações."

# Com contexto
"Você é o serviço de notificações de uma plataforma de e-commerce
com 50 mil usuários ativos. Precisamos garantir que cada evento
de compra gere as notificações corretas sem duplicatas."
```

A diferença é a mesma entre um RFC que começa com "Precisamos de notificações" e um que começa explicando o volume de eventos, os problemas atuais de duplicata, e o impacto no suporte.

## Proposed Solution -> Descrição da tarefa

A solução proposta no RFC diz *o que* vai ser construído. No prompt, a descrição da tarefa faz o mesmo: diz ao agente exatamente o que ele precisa fazer.

```
# Vago
"Manda as notificações certas."

# Preciso
"Para cada evento de compra recebido, determine os canais de
notificação aplicáveis (email, push, SMS) com base nas
preferências do usuário, gere o conteúdo da mensagem usando
o template correspondente, e enfileire para envio."
```

No RFC, a proposed solution tem verbos de ação e descreve fluxos. No prompt, idem. A clareza aqui é o que separa um agente produtivo de um agente perdido.

## Constraints -> Regras e limites

Essa é talvez a seção mais negligenciada -- e a mais poderosa. No RFC, as constraints dizem: "construa dentro dessas paredes." No prompt, as regras fazem o mesmo.

```
# Sem constraints
"Envia notificação por email."

# Com constraints
"Use apenas o provider SendGrid já configurado no projeto.
Não introduza novos serviços de email.
Rate limit: máximo 100 emails por minuto.
Todas as mensagens devem seguir os templates existentes em /templates."
```

É aqui que você evita que o agente tome decisões por conta. Sem constraints, ele escolhe o caminho que parece mais lógico para ele -- que raramente é o mais lógico para o seu projeto.

## Non-Goals -> Exclusões explícitas

Se constraints dizem o que fazer *dentro*, non-goals dizem o que fica *fora*. No mundo dos prompts, isso se traduz em exclusões explícitas -- os famosos "NÃO faça".

```
"NÃO implemente:
- Sistema de preferências de notificação (já existe)
- Retry automático de falhas (será tratado em fase posterior)
- Analytics de abertura de email
- Notificações em tempo real via WebSocket"
```

Parece óbvio? Para um humano experiente no projeto, talvez. Para um agente, não. Sem essas exclusões, um modelo capaz vai olhar para o domínio de notificações e *naturalmente* pensar em retry, analytics, real-time. Ele está tentando ser completo. Seu trabalho é dizer onde a completude termina.

## Open Questions -> Pedidos de esclarecimento

No RFC, open questions são pontos que o autor ainda não resolveu e quer discutir com o time. No prompt, isso se traduz em instruir o agente a perguntar antes de decidir.

```
"Se o usuário não tem preferência de canal configurada,
PERGUNTE qual canal usar em vez de assumir um padrão.
Se o template para o tipo de evento não existir,
PARE e reporte o erro em vez de gerar conteúdo genérico."
```

Essa seção transforma o agente de um executor cego em um colaborador. Em vez de preencher lacunas com suposições (que é o instinto natural do modelo), ele sinaliza incerteza. Exatamente como um bom engenheiro faria ao ler um RFC com pontos em aberto.

## Acceptance Criteria -> Formato de saída e critérios de sucesso

No RFC, critérios de aceite definem "como sabemos que deu certo." No prompt, eles definem o formato e a qualidade esperada da saída.

```
"Saída esperada para cada notificação processada:
- status: 'queued' | 'skipped' | 'error'
- channel: canal selecionado
- reason: motivo se skipped ou error
- timestamp: ISO 8601

Sucesso = todas as notificações processadas sem exceções
não tratadas, com log estruturado de cada decisão."
```

Sem critérios de aceite, como você sabe se o agente fez um bom trabalho? Você não sabe. Fica na intuição. E intuição não escala.

## Na prática: do RFC ao prompt

Chega de teoria. Vamos pegar um RFC fictício de um serviço de notificações e transformá-lo num prompt de sistema. Lado a lado.

### O RFC

```
TÍTULO: Serviço de Notificações para Eventos de Compra

PROBLEMA:
Atualmente, notificações de compra são disparadas inline
no controller de pedidos. Isso causa timeouts em picos de
tráfego e não há controle de duplicatas.

SOLUÇÃO PROPOSTA:
Criar um serviço assíncrono que consuma eventos de compra
de uma fila, determine os canais aplicáveis por usuário,
e enfileire as mensagens para envio via providers existentes.

RESTRIÇÕES:
- Usar a fila SQS já provisionada
- Providers: SendGrid (email), Firebase (push)
- Não criar novos templates; usar os existentes
- Latência máxima: 30s entre evento e enfileiramento

FORA DO ESCOPO:
- Notificações de marketing
- Sistema de preferências (já existe, apenas consumir)
- Retry de falhas de provider (fase 2)

QUESTÕES EM ABERTO:
- Devemos agregar notificações de múltiplos itens
  num mesmo pedido?
- Qual o fallback se o provider principal cair?

CRITÉRIOS DE ACEITE:
- Evento de compra gera notificação em < 30s
- Zero duplicatas por evento
- Log estruturado de cada decisão (canal, status, motivo)
```

### O prompt de sistema

```
PAPEL:
Você é o serviço de notificações de uma plataforma de
e-commerce. Sua função é processar eventos de compra
e garantir que cada evento gere as notificações corretas
sem duplicatas.

TAREFA:
Para cada evento de compra recebido:
1. Consulte as preferências de canal do usuário
2. Determine os canais aplicáveis (email via SendGrid,
   push via Firebase)
3. Selecione o template existente para o tipo de evento
4. Enfileire a mensagem para envio

REGRAS:
- Use APENAS SendGrid para email e Firebase para push
- Use APENAS templates existentes; não gere conteúdo livre
- Latência máxima entre receber evento e enfileirar: 30s
- Garanta idempotência: mesmo evento processado duas vezes
  não gera notificação duplicada

NÃO FAÇA:
- Não processe eventos de marketing
- Não modifique preferências de usuário; apenas leia
- Não implemente retry de falhas de provider
- Não crie novos templates

QUANDO TIVER DÚVIDA:
- Se um pedido tem múltiplos itens e você não sabe se
  deve agregar, PERGUNTE antes de processar
- Se o provider principal estiver indisponível, REPORTE
  o erro em vez de tentar alternativas

FORMATO DE SAÍDA:
Para cada notificação, retorne:
{
  "event_id": "string",
  "status": "queued | skipped | error",
  "channel": "email | push",
  "reason": "string (se skipped ou error)",
  "timestamp": "ISO 8601"
}
```

Olha os dois lado a lado. Cada seção do RFC mapeou diretamente para uma seção do prompt. O problema virou o papel. A solução virou a tarefa. As restrições viraram regras. O fora de escopo virou "NÃO FAÇA". As questões abertas viraram "QUANDO TIVER DÚVIDA". Os critérios de aceite viraram o formato de saída.

Não é coincidência. É a mesma estrutura de pensamento, aplicada a um interlocutor diferente.

## Vago vs. estruturado: o que muda na prática

Pra deixar o contraste claro, veja o que acontece quando você usa um prompt vago versus um prompt com estrutura de RFC.

**Prompt vago:**
```
"Cria um serviço de notificações pro meu e-commerce."
```

O agente provavelmente vai: escolher seus próprios providers, inventar um sistema de templates, implementar retry, adicionar analytics, criar um painel de preferências, e talvez até um sistema de A/B testing de mensagens. Tudo isso sem você pedir. Muito trabalho, pouco valor, e horas de limpeza pela frente.

**Prompt com estrutura de RFC:**

O que a gente escreveu acima. O agente faz exatamente o que foi pedido, nos limites que foram definidos, e sinaliza quando encontra algo que não sabe resolver.

Gergely Orosz, no Pragmatic Engineer, faz uma observação que cabe perfeitamente aqui: a forma como informação flui molda a cultura de um time. O mesmo vale para agentes. A estrutura do seu prompt molda o comportamento do agente.

## Escrita como quality gate

Uma última reflexão. Em times de engenharia maduros, o RFC passa por review antes de virar código. Alguém lê, questiona, aponta lacunas. É um quality gate.

Prompts de sistema merecem o mesmo tratamento. Se um prompt vai guiar o comportamento de um agente que interage com seu sistema de produção, ele deveria passar por um review tão rigoroso quanto um pull request.

Leia o prompt em voz alta. Pergunte: "se um dev junior lesse isso, ele saberia o que fazer?" Se a resposta é não, o agente também não vai saber. Revise. Peça feedback. Trate o prompt como artefato de engenharia, não como texto descartável.

## O que vem a seguir

Agora que você vê o espelho, o próximo passo é dominar uma das seções mais subestimadas: as restrições explícitas. No Artigo 4, vamos explorar por que o "NÃO faça" é tão poderoso quanto o "faça" -- e como constraints bem escritas evitam 80% dos problemas com agentes.

---

### Navegação da série

1. [O RFC que Ninguém Leu e o Prompt que Ninguém Escreveu](/blog/o-rfc-que-ninguem-leu-e-o-prompt-que-ninguem-escreveu) - A conexão fundamental
2. **Anatomia de um bom RFC** - Os elementos estruturais que funcionam
3. **Este artigo** - O espelho do RFC no mundo dos prompts
4. **Restrições explícitas** - O poder do "não faça"
5. **Interfaces e contratos** - Como agentes respeitam fronteiras
6. **Critérios de aceite** - Quando o agente sabe que terminou
7. **Loops de feedback** - Onde o prompt vai além do RFC
8. **Contexto compartilhado** - O que RFCs assumem e agentes precisam ouvir
9. **O documento único** - Escrevendo para humanos e agentes ao mesmo tempo
10. **O futuro da especificação** - Quando o RFC é o código

---

Curtiu o mapeamento? Quer discutir como aplicar isso no seu time? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
