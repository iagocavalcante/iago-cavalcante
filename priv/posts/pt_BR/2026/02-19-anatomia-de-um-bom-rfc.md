%{
  title: "Anatomia de um Bom RFC",
  author: "Iago Cavalcante",
  tags: ~w(ia engenharia-de-software rfcs prompts agentes desenvolvimento),
  description: "Todo RFC que funciona tem seis peças essenciais. Se você sabe montar essas peças para humanos, já sabe montar para agentes de IA.",
  locale: "pt_BR",
  published: false,
  scheduled_for: ~D[2026-02-19]
}
---

Fala, galera! Vou começar com uma história que parece bobeira, mas acontece toda semana em algum time de engenharia pelo mundo.

Um time de cinco devs gastou três sprints construindo um sistema de notificações. Push notifications, email, SMS, webhook -- o pacote completo. No dia da demo, o product manager olhou pra tela e disse: "Legal, mas a gente só precisava de email. E só pra recuperação de senha."

Três sprints. Cinco engenheiros. Um mês de trabalho. Tudo porque ninguém parou pra escrever o que exatamente precisava ser feito -- e, mais importante, **o que NÃO precisava ser feito**.

Se esse time tivesse escrito um RFC antes de abrir o editor de código, teriam descoberto em trinta minutos que o escopo era dez vezes menor do que imaginavam. Mas não escreveram. E pagaram caro.

## As seis peças que todo bom RFC tem

No [artigo anterior](/blog/o-rfc-que-ninguem-leu-e-o-prompt-que-ninguem-escreveu), eu mostrei que a estrutura de um RFC é essencialmente a mesma de um bom prompt. Hoje vamos abrir essa estrutura peça por peça e entender **por que cada uma existe** e o que acontece quando você pula alguma.

Todo RFC que funciona -- de verdade, não só no papel -- tem seis seções. Não são opcionais. Cada uma previne uma categoria inteira de falhas.

Vamos usar o mesmo exemplo de autenticação do artigo anterior, mas agora evoluído pra mostrar como cada seção se conecta.

## 1. Problem Statement -- O porquê antes do como

A primeira seção de qualquer RFC deveria responder uma pergunta simples: **por que estamos fazendo isso?**

Parece óbvio, mas a maioria dos documentos técnicos pula direto pra solução. "Vamos implementar OAuth2 com Google e GitHub." Legal. Mas por quê? Qual problema isso resolve? Quem está sendo afetado? Qual é o custo de não fazer nada?

Para o nosso exemplo de autenticação:

```
## Problem Statement

Atualmente, qualquer pessoa com o link pode acessar o painel
administrativo. Não existe identificação de usuários, o que impede:

- Auditoria de quem alterou configurações
- Personalização da experiência por perfil
- Conformidade com LGPD (sem saber quem é o usuário,
  não conseguimos atender pedidos de exclusão de dados)

Nos últimos 30 dias, tivemos 3 incidentes onde configurações
foram alteradas sem que pudéssemos identificar o responsável.
```

**O que acontece quando essa seção falta:** o time constrói a coisa certa da forma errada, ou a coisa errada da forma certa. Sem entender o problema, qualquer solução parece válida. E é aí que você gasta três sprints num sistema de notificações que ninguém pediu.

**A regra de ouro:** se você não consegue explicar o problema sem mencionar a solução, você ainda não entendeu o problema.

## 2. Proposed Solution -- O como, separado do porquê

Agora sim. Depois de definir o problema com clareza, você propõe como resolver.

A separação entre problema e solução parece sutil, mas faz toda diferença. Quando você mistura os dois, ninguém consegue questionar a solução sem parecer que está questionando a existência do problema.

```
## Proposed Solution

Implementar autenticação por email e senha usando phx_gen_auth:

1. Gerar o módulo de autenticação com `mix phx.gen.auth Accounts User users`
2. Configurar confirmação de email via token (validade: 24h)
3. Adicionar plug de autenticação nas rotas do painel administrativo
4. Criar página de login com formulário de email/senha

Stack técnica:
- Argon2 para hash de senhas (já é dependência do projeto)
- Swoosh + Resend para envio de emails transacionais
- Sessão baseada em cookie com validade de 60 dias
```

**O que acontece quando essa seção é vaga:** cada dev interpreta de um jeito. Um usa bcrypt, outro usa Argon2. Um cria tabelas novas, outro reaproveita as existentes. No final, o merge request é um Frankenstein.

## 3. Constraints -- As cercas do playground

Restrições são as regras do jogo. Elas definem o espaço dentro do qual a solução precisa existir. Podem ser técnicas, de negócio, de tempo, de compliance -- qualquer coisa que limita suas opções.

```
## Constraints

- DEVE usar a estrutura de Accounts que já existe no projeto
  (não criar contexto novo)
- DEVE usar Argon2 para hash de senhas (padrão do time)
- NÃO pode adicionar dependências externas de autenticação
  (Guardian, Pow, etc.) -- usar phx_gen_auth puro
- O deploy precisa ser compatível com a infra atual no Fly.io
- Tempo máximo de implementação: 1 sprint (2 semanas)
```

**O que acontece quando essa seção falta:** liberdade demais. O dev (ou o agente) escolhe a biblioteca mais popular do momento, que pode não ser compatível com o projeto. Ou otimiza pra performance quando o requisito real é simplicidade.

Restrições não são limitações -- são decisões já tomadas que evitam retrabalho.

## 4. Non-Goals (Fora do Escopo) -- A seção mais subestimada

Essa é, de longe, **a seção mais importante e mais ignorada** de qualquer RFC.

Non-goals não são coisas que você não quer fazer. São coisas que alguém razoável poderia assumir que fazem parte do escopo, mas que você está explicitamente excluindo. A diferença é sutil mas crucial.

```
## Non-Goals (Fora do Escopo)

- Recuperação de senha (será tratada no próximo ciclo, RFC-005)
- Login social (Google, GitHub) -- avaliação prevista para Q3
- Autenticação de dois fatores (2FA)
- Sistema de roles/permissões (RBAC)
- API de autenticação para clientes externos (apenas web)
- Rate limiting em tentativas de login (será feito via Cloudflare)
```

**O que acontece quando essa seção falta:** escopo infinito. Cada reviewer do RFC vai sugerir "mas e se a gente também fizesse X?" E se você não tem um lugar explícito pra dizer "não, X fica pra depois", o escopo cresce até engolir o cronograma.

Eu já vi RFCs onde a seção de non-goals era maior que a seção de solução proposta. E esses eram os melhores RFCs. Porque **dizer o que você NÃO vai fazer é tão importante quanto dizer o que vai**.

## 5. Open Questions -- A seção da honestidade

Essa seção é onde você admite o que não sabe. E isso é poderoso.

Todo projeto tem incógnitas. A diferença entre um bom RFC e um ruim é que o bom não finge que tem todas as respostas.

```
## Open Questions

1. Devemos permitir múltiplas sessões simultâneas por usuário?
   - Proposta inicial: sim, com limite de 5 sessões ativas
   - Precisamos validar com produto se isso gera risco de segurança

2. Qual o comportamento quando o token de confirmação expira?
   - Opção A: usuário precisa se registrar novamente
   - Opção B: reenvio automático de email com novo token

3. Precisamos de log estruturado para eventos de autenticação
   desde o dia 1 ou podemos adicionar depois?
```

**O que acontece quando essa seção falta:** as perguntas aparecem no meio do desenvolvimento. E aí a resposta vira uma decisão de corredor que não fica documentada em lugar nenhum. Dois meses depois, ninguém lembra por que foi decidido daquele jeito.

Open questions não são fraqueza. São maturidade técnica.

## 6. Acceptance Criteria -- Como saber que terminou

A última peça é a mais pragmática: como saber que deu certo?

Sem critérios de aceite, "pronto" vira uma negociação. O dev acha que terminou, o QA discorda, o PM tem outra definição, e o stakeholder tem uma quarta.

```
## Acceptance Criteria

- [ ] Usuário consegue se registrar com email e senha
- [ ] Email de confirmação é enviado em menos de 30 segundos
- [ ] Usuário consegue fazer login após confirmar email
- [ ] Usuário NÃO consegue acessar rotas protegidas sem login
- [ ] Sessão expira após 60 dias de inatividade
- [ ] Tentativa de login com credenciais inválidas retorna
      mensagem genérica (sem revelar se email existe)
- [ ] Testes automatizados cobrem todos os fluxos acima
```

**O que acontece quando essa seção falta:** o projeto nunca termina. Sempre tem mais uma coisa pra ajustar, mais um edge case pra cobrir, mais um cenário pra testar. Acceptance criteria são a linha de chegada.

## Isso não é só teoria

Esse modelo de seis seções não é invenção minha. É uma prática validada pela indústria.

Gergely Orosz, no Pragmatic Engineer, descreve um processo de RFC em cinco etapas -- planejar antes de construir, documentar, buscar aprovação, distribuir para feedback e iterar. A Uber escalou esse processo de dezenas para milhares de engenheiros. Google usa design docs, Facebook, Microsoft e Amazon têm processos similares.

O padrão é o mesmo: **antes de escrever código, escreva o que o código vai fazer, o que não vai fazer, e como saber se deu certo.**

## O anti-padrão: o RFC sem non-goals

Se eu tivesse que escolher a falha mais comum em RFCs, seria a ausência de non-goals. E sabe por quê? Porque não escrever non-goals parece eficiente. "A gente só precisa descrever o que vai fazer, né?"

Não. Porque sem non-goals:

- O reviewer sugere features extras que inflam o escopo
- O dev assume que coisas adjacentes fazem parte do trabalho
- O agente de IA inventa funcionalidades "porque faz sentido"

Non-goals são o freio do projeto. Sem freio, qualquer carro bate.

## A ponte pro próximo artigo

Olha as seis seções de novo:

1. Problem Statement
2. Proposed Solution
3. Constraints
4. Non-Goals
5. Open Questions
6. Acceptance Criteria

Agora pensa: como cada uma dessas se traduz pra um system prompt de agente de IA?

O problem statement vira o contexto. As constraints viram as regras. Os non-goals viram as exclusões explícitas. Os acceptance criteria viram o formato de saída esperado. As open questions... bom, essas viram algo que RFCs tradicionais não têm -- mas prompts precisam ter.

Na próxima semana, a gente faz exatamente essa tradução. Peça por peça.

---

**Série: RFCs como Prompts para Desenvolvimento com Agentes de IA**

1. [O RFC que Ninguém Leu e o Prompt que Ninguém Escreveu](/blog/o-rfc-que-ninguem-leu-e-o-prompt-que-ninguem-escreveu) - A conexão fundamental
2. **Anatomia de um Bom RFC** - Os elementos estruturais que funcionam *(este artigo)*
3. **Anatomia de um bom prompt de sistema** - O espelho do RFC
4. **Restrições explícitas** - O poder do "não faça"
5. **Interfaces e contratos** - Como agentes respeitam fronteiras
6. **Critérios de aceite** - Quando o agente sabe que terminou
7. **Loops de feedback** - Onde o prompt vai além do RFC
8. **Contexto compartilhado** - O que RFCs assumem e agentes precisam ouvir
9. **O documento único** - Escrevendo para humanos e agentes ao mesmo tempo
10. **O futuro da especificação** - Quando o RFC é o código

---

Curtiu? Tem alguma seção de RFC que você acha que deveria estar na lista? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
