%{
  title: "Onde o Prompt Vai Além do RFC: Loops de Feedback",
  author: "Iago Cavalcante",
  tags: ~w(ia engenharia-de-software rfcs prompts agentes desenvolvimento),
  description: "RFCs são documentos estáticos. Prompts são conversas interativas. Quando você combina a disciplina de um com a flexibilidade do outro, a mágica acontece.",
  locale: "pt_BR",
  published: false,
  scheduled_for: ~D[2026-03-26]
}
---

Fala, pessoal! Até agora, tudo mapeou perfeitamente. RFCs para prompts, um pra um. Mas hoje a gente quebra a simetria.

Nos seis artigos anteriores, eu mostrei como a disciplina dos RFCs se traduz diretamente pro mundo dos prompts: estrutura, restrições, interfaces, critérios de aceite. Cada seção do RFC encontrou seu espelho no prompt de sistema. Foi bonito, foi útil, e ainda vale.

Mas se a história parasse aí, prompt seria só um RFC com outra roupa. E não é. A partir deste artigo, a conversa muda. Porque prompts fazem algo que RFCs simplesmente não conseguem: **eles conversam de volta.**

## O documento que não responde

Vamos ser justos com o RFC. Ele é um artefato brilhante de engenharia de software. Ele organiza pensamento, alinha times, documenta decisões. Dezenas de anos de prática provaram que funciona.

Mas ele é estático.

Quando um RFC é aprovado, ele vira referência. Você não "conversa" com um RFC. Não diz "ei, aquela parte sobre autenticação, muda pra OAuth2 em vez de JWT." Você escreve um novo RFC. Ou uma emenda. Ou abre uma thread no Slack que ninguém vai ler daqui a dois meses.

O ciclo de feedback de um RFC é lento por design. Escrita, review, aprovação, implementação, retrospectiva. Cada etapa pode levar dias ou semanas. E tudo bem -- pra decisões arquiteturais de longo prazo, essa cadência faz sentido. Você quer deliberação, não velocidade.

Mas quando o "leitor" do seu documento é um agente de IA que executa em segundos, esse ciclo lento vira um gargalo. Você escreveu o prompt perfeito (com toda a disciplina de RFC que a gente discutiu), mandou pro agente, recebeu o resultado... e percebeu que faltou um detalhe. Que uma premissa estava errada. Que o contexto mudou entre a escrita e a execução.

O que você faz? Com um RFC, você volta pro começo. Com um prompt, você **continua a conversa.**

## O superpoder que RFCs não têm

A interatividade é o superpoder dos prompts. E ela se manifesta em três padrões de feedback que eu vejo consistentemente nos melhores workflows com agentes.

### Padrão 1: Contexto incremental

Você não precisa saber tudo antes de começar. Pode começar com o que sabe e adicionar informação conforme o agente trabalha.

```
[Prompt inicial]
Crie um módulo de processamento de pagamentos.
Use Stripe como provider. Suporte a cartão de crédito.

[Após ver o resultado da Fase 1]
Agora adicione suporte a PIX. O endpoint é /api/pix
do nosso gateway interno. Use o mesmo padrão de error
handling que você criou pro cartão.

[Após ver o resultado da Fase 2]
O time de compliance acabou de confirmar: precisamos
de idempotency key em todas as transações. Adicione isso
nas funções que você já criou, usando UUID v4.
```

Num RFC, essa informação teria que estar toda lá desde o início -- ou você teria que escrever uma emenda formal. No prompt, você adiciona contexto conforme ele se torna disponível. O agente absorve e adapta.

### Padrão 2: Memória multi-turn

Cada resposta do agente carrega o contexto das interações anteriores. Isso permite construir complexidade de forma incremental, sem repetir tudo a cada mensagem.

```
[Turn 1] "Crie o schema de usuário com nome e email."
[Turn 2] "Adicione validação de formato no email."
[Turn 3] "Agora crie o changeset de registro com
          confirmação de senha."
[Turn 4] "Refatore: extraia as validações de email
          pra um módulo compartilhado."
```

Cada turn constrói sobre o anterior. O agente não esquece o que fez no turn 1 quando chega no turn 4. Ele tem o contexto acumulado. Isso é algo que um documento estático simplesmente não oferece -- você não pode "construir sobre" um RFC de forma iterativa em tempo real.

### Padrão 3: Correção sem recomeço

Talvez o padrão mais valioso. Você pode corrigir o curso do agente sem descartar tudo e começar do zero.

```
[Prompt] "Crie uma API REST para gerenciamento de tarefas."
[Resultado] O agente criou com autenticação via API key.

[Correção] "A autenticação deveria ser via JWT, não API key.
Mantém todo o resto, só troca o mecanismo de auth."
```

O agente mantém 90% do trabalho e ajusta os 10% que precisavam mudar. Num fluxo baseado em RFC puro, a correção significaria: anotar o problema, atualizar o documento, re-submeter pra review, e aí sim implementar. Com o prompt, a correção é instantânea e cirúrgica.

## Duas equipes, dois mundos

Pra deixar a diferença concreta, imagina dois times trabalhando no mesmo problema: construir um serviço de recomendações de produto.

**Time A -- o prompt como RFC congelado:**

O Time A escreve um prompt detalhado e completo. Estrutura de RFC, restrições, critérios de aceite, tudo no lugar. Manda pro agente. Aceita o resultado. Se não gostou, reescreve o prompt inteiro e tenta de novo.

O resultado costuma ser bom na primeira tentativa -- afinal, o prompt foi bem escrito. Mas quando precisa de ajuste, o custo é alto. Cada iteração é um ciclo completo de escrita-execução-avaliação. Em um dia de trabalho, o Time A consegue fazer talvez 3 ou 4 iterações significativas.

**Time B -- o prompt com checkpoints de feedback:**

O Time B escreve o mesmo prompt inicial com a mesma disciplina. Mas divide a execução em fases com pontos de revisão.

```
Fase 1: Defina os tipos de dados e o schema do serviço
de recomendação.
→ [CHECKPOINT] Entregue o schema. Eu vou revisar antes
  de prosseguir.

Fase 2: Implemente a lógica de scoring básica.
→ [CHECKPOINT] Entregue a função de scoring. Eu vou
  validar os pesos.

Fase 3: Crie os endpoints da API.
→ [CHECKPOINT] Entregue os endpoints. Eu vou testar
  antes da integração.

Fase 4: Adicione cache e otimizações.
→ [CHECKPOINT] Entregue a versão final.
```

Entre cada checkpoint, o Time B revisa, ajusta, adiciona contexto. "O schema ficou bom, mas adiciona um campo de categoria." "A função de scoring precisa considerar sazonalidade -- aqui estão os dados." "Os endpoints estão ótimos, mas muda o formato de resposta pra esse padrão."

Em um dia de trabalho, o Time B faz dezenas de micro-iterações. O resultado final é mais refinado, mais alinhado com o que o time realmente precisa, e com menos retrabalho.

A diferença não é que o Time B escreve prompts melhores. É que o Time B **trata o prompt como uma conversa**, não como um documento entregue.

## O anti-padrão: "prompt and pray"

Se você reconheceu o Time A, não se sinta mal. A maioria de nós começa aí. Eu chamo isso de **"prompt and pray"** -- escrever o prompt, mandar pro agente, e torcer pro resultado ser bom.

É o equivalente a escrever um RFC, distribuir pro time, e nunca perguntar se alguém leu. Ou se concordou. Ou se a implementação seguiu o que estava escrito.

O "prompt and pray" tem uma ilusão de eficiência. Parece rápido porque você só escreve uma vez. Mas o tempo que você economiza na escrita, você gasta em dobro na avaliação e no retrabalho. Quando o resultado não bate, você descarta tudo e tenta de novo do zero. É como fazer deploy sem testes -- pode funcionar, mas quando não funciona, o custo é brutal.

## Template: checkpoints de feedback em workflows com agentes

Se você quer sair do "prompt and pray" e adotar feedback loops, aqui vai um template que funciona bem na prática:

```
## Contexto
[Descrição do problema, papel do agente, restrições
-- toda a disciplina de RFC que a gente já discutiu]

## Execução em fases

### Fase 1: [Nome descritivo]
Entregáveis: [O que o agente deve produzir]
Formato: [Como deve entregar]
→ PARE aqui e aguarde meu review antes de continuar.

### Fase 2: [Nome descritivo]
Pré-requisito: Aprovação da Fase 1
Entregáveis: [O que o agente deve produzir]
Formato: [Como deve entregar]
→ PARE aqui e aguarde meu review antes de continuar.

### Fase 3: [Nome descritivo]
Pré-requisito: Aprovação da Fase 2
Entregáveis: [O que o agente deve produzir]
Formato: [Como deve entregar]

## Regras de feedback
- Se eu pedir uma alteração, aplique APENAS a alteração
  solicitada. Não refatore ou "melhore" outras partes.
- Se algo no meu feedback for ambíguo, PERGUNTE antes
  de implementar.
- Mantenha o contexto de todas as fases anteriores.
```

O segredo está nas instruções de parada. Quando você diz ao agente "PARE aqui e aguarde meu review", você cria um ponto natural de feedback. O agente entrega um pedaço, você avalia, ajusta, e só então ele continua. É como um code review em tempo real, mas com ciclos de minutos em vez de horas.

## O insight central

A melhor forma de trabalhar com agentes não é escolher entre disciplina de RFC e feedback loops. É combinar os dois.

A disciplina do RFC te dá a estrutura inicial: contexto claro, restrições explícitas, critérios de aceite definidos. Sem isso, seus feedback loops são caóticos -- você fica corrigindo problemas que boas restrições teriam evitado.

Os feedback loops te dão a flexibilidade que o RFC não tem: capacidade de adaptar, corrigir, e refinar em tempo real. Sem isso, você fica preso no "prompt and pray", torcendo pra acertar tudo na primeira tentativa.

**RFC sem feedback = rigidez.** Bom resultado na primeira tentativa, alto custo quando precisa mudar.

**Feedback sem RFC = caos.** Muita iteração, pouca direção, resultado imprevisível.

**RFC + feedback = engenharia de prompt de verdade.** Estrutura que direciona, flexibilidade que refina.

## O que vem por aí

Se feedback loops são sobre a conversa entre você e o agente, o próximo artigo é sobre o que acontece quando essa conversa precisa de contexto que vai além do prompt. Vamos falar sobre **contexto compartilhado** -- a informação que RFCs assumem que todo mundo sabe e que agentes precisam ouvir explicitamente.

---

### Série: RFCs como Prompts para Desenvolvimento com Agentes de IA

1. [A conexão fundamental](/blog/o-rfc-que-ninguem-leu-e-o-prompt-que-ninguem-escreveu)
2. [Anatomia de um bom RFC](/blog/anatomia-de-um-bom-rfc)
3. [Anatomia de um bom prompt de sistema](/blog/anatomia-de-um-bom-prompt-de-sistema)
4. [Restrições explícitas — O poder do "não faça"](/blog/restricoes-explicitas-o-poder-do-nao-faca)
5. Interfaces e contratos *(em breve)*
6. Critérios de aceite *(em breve)*
7. **Loops de feedback** *(este artigo)*
8. Contexto compartilhado *(em breve)*
9. O documento único *(em breve)*
10. O futuro da especificação *(em breve)*

---

Curtiu? Quer trocar ideia sobre como usar feedback loops nos seus workflows? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
