%{
  title: "O Futuro da Especificação: Quando o RFC É o Código",
  author: "Iago Cavalcante",
  tags: ~w(ia engenharia-de-software rfcs prompts agentes desenvolvimento),
  description: "A linha entre especificação e implementação está desaparecendo. O desenvolvedor que escreve a melhor especificação vai entregar mais rápido que o que digita o código mais rápido.",
  locale: "pt_BR",
  published: false,
  scheduled_for: ~D[2026-04-16]
}
---

Fala, pessoal! Dez semanas. Uma ideia. Vamos fechar o ciclo.

Ao longo desta série, eu defendi uma tese simples: a mesma disciplina que faz um RFC funcionar para engenheiros humanos é a que faz um prompt funcionar para agentes de IA. Passamos por estrutura, restrições, interfaces, critérios de aceite, feedback loops, contexto compartilhado, e o documento unificado. Cada artigo construiu sobre o anterior, mostrando que escrever para máquinas e escrever para pessoas é, no fundo, a mesma habilidade.

Mas essa série não seria completa se a gente só olhasse pra trás. Hoje eu quero olhar pra frente. Porque se RFCs e prompts são a mesma disciplina, o que acontece quando os agentes ficam bons o suficiente pra que a especificação *seja* a implementação?

## As quatro fases da especificação

Pensa comigo na evolução da relação entre quem especifica e quem implementa.

**Fase 1: O humano especifica, o humano constrói.** Esse é o mundo que a gente conhece há décadas. Alguém escreve um RFC, design doc ou tech spec. Outro alguém (ou o mesmo alguém) lê, interpreta, e escreve o código. O documento é referência. O código é a entrega. São dois artefatos distintos, conectados por interpretação humana.

**Fase 2: O humano especifica, o agente constrói.** Esse é o mundo que a gente explorou ao longo da série. Você escreve o prompt com disciplina de RFC -- contexto, restrições, critérios de aceite -- e o agente gera o código. Ainda são dois artefatos. Mas a tradução entre eles ficou mais rápida. Minutos em vez de dias.

**Fase 3: O humano especifica, a especificação instrui diretamente.** Aqui a coisa muda de natureza. A especificação não é mais um documento que alguém lê e depois implementa. Ela é a instrução de build. O agente não "interpreta" o RFC -- ele o executa. O documento e o código começam a se fundir.

**Fase 4: Especificação é implementação.** O estado final. A descrição precisa o suficiente do que você quer *é* o artefato executável. Não existe mais a etapa de "agora transforma isso em código." O "isso" já é código. Ou melhor: a distinção entre especificação e código deixou de fazer sentido.

## Onde estamos agora

Nós estamos entre as fases 2 e 3. E a transição está acontecendo rápido.

Se você usou um agente de IA para programar nos últimos seis meses, você sentiu isso. O gap entre "descrever o que eu quero" e "ter algo funcionando" está encolhendo. Não desapareceu -- ainda precisa revisar, ajustar, corrigir. Mas a distância diminuiu de forma perceptível.

Há dois anos, pedir pra um agente "criar um sistema de autenticação com email e senha, confirmação por token, sessão de 60 dias" resultava em código genérico que precisava de horas de ajuste. Hoje, com as restrições certas (as mesmas que a gente discutiu nos artigos sobre restrições e interfaces), o resultado é utilizável na primeira tentativa. Não perfeito. Mas utilizável.

E a cada mês, a quantidade de ajuste necessário diminui.

## A habilidade que importa muda

Essa transição tem uma implicação profunda pra quem desenvolve software.

Quando a tradução de especificação para código era manual, a habilidade mais valorizada era a tradução em si. Saber a linguagem. Conhecer os frameworks. Dominar os padrões de design. Digitar rápido. Debugar rápido. A velocidade de implementação era o diferencial.

Quando a tradução é automatizada, a habilidade mais valorizada muda. Passa a ser a qualidade da especificação.

Pensa assim: se dois desenvolvedores têm acesso ao mesmo agente, o que diferencia o resultado de cada um? Não é a velocidade de digitação. Não é o conhecimento de sintaxe. É a clareza com que cada um descreve o que quer construir. É a precisão das restrições. É a completude dos critérios de aceite. É, no fundo, tudo que a gente discutiu nessa série.

**O desenvolvedor que escreve a melhor especificação vai entregar mais rápido que o que digita o código mais rápido.**

Lê essa frase de novo. Ela parece provocativa, mas é uma consequência lógica do que já está acontecendo.

## Libertação, não ameaça

Eu sei o que você pode estar pensando. "Se agentes vão escrever todo o código, pra que precisa de desenvolvedor?"

A resposta é a mesma de sempre: alguém precisa decidir *o que* construir e *por que*. E essa parte ficou mais importante, não menos.

Quando você gasta 80% do seu dia traduzindo uma ideia em sintaxe, sobra 20% pra pensar na ideia em si. Quando um agente cuida da tradução, os 80% ficam livres pra arquitetura. Pra design. Pra entender o problema do usuário. Pra fazer as perguntas certas antes de começar a construir.

Isso não é uma ameaça. É uma libertação.

Menos tempo brigando com compiladores. Menos tempo debugando erros de tipo. Menos tempo escrevendo boilerplate. Mais tempo pensando em o que importa de verdade: o problema que precisa ser resolvido e a melhor forma de resolvê-lo.

Os desenvolvedores mais eficientes que eu conheço já trabalham assim. Eles passam mais tempo no whiteboard que no editor. Mais tempo definindo o problema que escrevendo a solução. E quando finalmente sentam pra codificar, o código sai rápido porque a especificação já está clara na cabeça. O agente só acelera isso.

## O que muda na prática

Se a especificação está se tornando o artefato principal, algumas coisas mudam no dia a dia.

**Code review se torna spec review.** Se o agente gera código a partir de uma especificação, revisar o código sem revisar a spec é como revisar o resultado sem revisar a premissa. O code review mais valioso vai ser o que questiona a especificação: "Por que essa restrição? Faz sentido esse escopo? Faltou cenário de erro?"

**Documentação se torna código.** Se a especificação é executável, a documentação não é mais um artefato separado que fica desatualizado. Ela *é* a implementação. Atualizou a spec, atualizou o sistema. Isso resolve um dos problemas mais antigos da engenharia de software: documentação que mente.

**Onboarding acelera.** Se o sistema é descrito pela sua especificação, um novo membro do time não precisa ler milhares de linhas de código pra entender o que o sistema faz. Lê a spec. A spec é a verdade.

**Debug muda de natureza.** Quando algo quebra, a pergunta muda de "qual linha de código tem o bug?" para "qual parte da especificação está incorreta ou incompleta?" O bug está na intenção, não na tradução.

## Olhando pra trás: o que a gente construiu

Vamos recapitular a jornada inteira.

No artigo 1, estabelecemos a ponte: RFCs e prompts são a mesma disciplina de comunicação de intenção. No artigo 2, dissecamos a anatomia de um bom RFC e vimos que cada seção tem um propósito. No artigo 3, fizemos o espelho: a anatomia de um bom prompt de sistema segue a mesma estrutura.

No artigo 4, mergulhamos nas restrições explícitas -- o poder de dizer "não faça" é tão grande pra agentes quanto pra humanos. No artigo 5, falamos de interfaces e contratos, a cola que mantém sistemas compostos funcionando. No artigo 6, definimos critérios de aceite como o sinal de parada que agentes precisam.

No artigo 7, quebramos a simetria: prompts vão além de RFCs porque conversam de volta. Feedback loops são o superpoder. No artigo 8, abordamos contexto compartilhado -- o que humanos assumem implicitamente e agentes precisam ouvir explicitamente. E no artigo 9, juntamos tudo: o documento unificado que serve humanos e agentes ao mesmo tempo.

Dez artigos. Uma tese. A ponte está construída.

## O que vem depois da série

Essa série vai virar livro.

Um livro bilíngue, expandido, com exemplos práticos aprofundados e um apêndice de templates prontos pra usar. Os conceitos que apresentei em 1500 palavras por artigo vão ganhar espaço pra respirar: mais cenários, mais edge cases, mais nuance.

Fique de olho nos meus canais pra novidades sobre o lançamento.

## Comece agora

Se essa série te convenceu de uma coisa, espero que seja esta: **escreva suas especificações como se um agente fosse ler. Porque em breve, um vai.**

Não amanhã. Não "no futuro." Agora.

Da próxima vez que você abrir o editor pra escrever um prompt, aplique o que a gente discutiu. Contexto claro. Restrições explícitas. Critérios de aceite verificáveis. Interfaces definidas. Checkpoints de feedback. Contexto compartilhado exposto.

Não porque é divertido (embora seja). Mas porque essa é a habilidade que vai separar quem entrega de quem só digita. A disciplina de especificação é a disciplina de pensamento. E pensar com clareza nunca sai de moda.

Obrigado por ter ficado comigo ao longo dessas dez semanas. A conversa não acaba aqui -- muda de formato. Nos vemos no livro.

---

### Série: RFCs como Prompts para Desenvolvimento com Agentes de IA

1. [A conexão fundamental](/blog/o-rfc-que-ninguem-leu-e-o-prompt-que-ninguem-escreveu)
2. [Anatomia de um bom RFC](/blog/anatomia-de-um-bom-rfc)
3. [Anatomia de um bom prompt de sistema](/blog/anatomia-de-um-bom-prompt-de-sistema)
4. [Restrições explícitas — O poder do "não faça"](/blog/restricoes-explicitas-o-poder-do-nao-faca)
5. [Interfaces e contratos](/blog/interfaces-e-contratos)
6. [Critérios de aceite](/blog/criterios-de-aceite)
7. [Loops de feedback](/blog/onde-o-prompt-vai-alem-do-rfc)
8. Contexto compartilhado *(em breve)*
9. O documento único *(em breve)*
10. **O futuro da especificação** *(este artigo)*

---

Curtiu a série? Quer continuar a conversa? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
