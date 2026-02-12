%{
  title: "O RFC que Ninguém Leu e o Prompt que Ninguém Escreveu",
  author: "Iago Cavalcante",
  tags: ~w(ia engenharia-de-software rfcs prompts agentes desenvolvimento),
  description: "A mesma disciplina que faz um RFC funcionar para engenheiros humanos é a que faz um prompt funcionar para agentes de IA. A maioria dos desenvolvedores já tem essa habilidade - só não percebeu ainda.",
  locale: "pt_BR",
  published: true
}
---

Fala, pessoal! Deixa eu começar com uma cena que todo dev já viveu.

Sexta-feira, 16h. Você abre o Jira e lá está o ticket fresquinho: **"Adicionar autenticação no sistema."** Só isso. Sem contexto, sem restrições, sem critérios de aceite. Nada.

Se você tem experiência, sabe o que vem a seguir: meia hora de perguntas no Slack. "Autenticação como? OAuth? JWT? Magic link? Precisa de 2FA? Quais providers? Tem federação? O front já tem tela de login?" Quinze perguntas pra conseguir começar a trabalhar.

Agora imagina que em vez de você, quem recebe esse ticket é um agente de IA. O que acontece?

Ele não pergunta. Ele constrói. E constrói errado.

Sem restrições, o agente decide por você. Implementa OAuth com Google, cria tabelas de sessão que conflitam com o schema existente, adiciona bcrypt onde você usa Argon2, e de brinde ainda gera um sistema de permissões que ninguém pediu. Três horas de trabalho jogadas fora.

A culpa não é do agente. A culpa é do ticket.

## O ticket vago é o inimigo universal

Esse é o ponto que pouca gente conecta: **o mesmo problema que faz um dev humano travar é o que faz um agente de IA alucinar.** Falta de contexto, falta de fronteiras, falta de definição clara do que "pronto" significa.

Sabe o que resolve isso há décadas? Um RFC.

Não estou falando necessariamente do RFC formal do IETF, aqueles documentos que definiram o TCP e o HTTP. Estou falando do conceito: um documento que descreve um problema, propõe uma solução, explicita o que NÃO faz parte do escopo, e define como saber se deu certo.

Times de engenharia mundo afora usam alguma variação disso. Design doc, ADR, tech spec - o nome muda, a função é a mesma. E essa função é mais relevante hoje do que nunca.

## Quando o RFC encontra o prompt

Aqui vem a sacada que mudou minha forma de trabalhar com agentes de IA.

Pega aquele ticket vago - "Adicionar autenticação" - e transforma num mini-RFC:

**Problema:** Usuários acessam o sistema sem identificação. Precisamos de login para personalizar a experiência e proteger dados sensíveis.

**Solução proposta:** Autenticação por email e senha usando `phx_gen_auth`, com confirmação de email via token.

**Restrições:**
- Usar a estrutura de accounts que já existe no projeto
- Senhas com Argon2 (padrão do projeto)
- Sem OAuth por enquanto
- Sem sistema de permissões/roles nesta fase

**Fora do escopo:**
- Recuperação de senha (próximo ciclo)
- Login social (Google, GitHub)
- 2FA

**Critérios de aceite:**
- Usuário consegue se registrar com email e senha
- Usuário recebe email de confirmação
- Usuário consegue fazer login após confirmar email
- Sessão expira após 60 dias de inatividade

Agora lê isso de novo. Mas desta vez, em vez de pensar como um documento para um time de engenharia, pensa como um prompt para um agente de IA.

Percebeu?

**É a mesma coisa.**

O problema vira o contexto. As restrições viram as regras. O fora de escopo vira as exclusões explícitas. Os critérios de aceite viram o formato de saída esperado. A estrutura que funciona para comunicar intenção entre humanos é exatamente a que funciona para comunicar intenção para máquinas.

## O RFC é um prompt para humanos. O prompt é um RFC para agentes.

Essa é a tese central desta série de artigos. E ela tem uma implicação que poucos percebem: **a maioria dos desenvolvedores já sabe escrever bons prompts - só nunca conectou as duas coisas.**

Se você já escreveu um design doc decente, você sabe ser específico sobre restrições. Se você já definiu critérios de aceite numa história de usuário, você sabe dizer para um agente quando parar. Se você já escreveu uma seção de "non-goals" num RFC, você sabe evitar que o agente invente funcionalidades que ninguém pediu.

A habilidade existe. O que falta é a ponte.

## O anti-padrão: o prompt-ticket

Sabe o que a maioria das pessoas faz quando trabalha com um agente de IA? Escreve o equivalente digital daquele ticket vago do Jira:

```
"Cria um sistema de autenticação pro meu app Phoenix"
```

E depois reclama que o resultado não é o que queria. Pior - fica num loop de correções incrementais:

```
"Não, usa Argon2 em vez de bcrypt"
"Ah, e não precisa de OAuth"
"Espera, tira o sistema de roles"
"O schema conflitou, corrige aí"
```

Cada correção é um mini-RFC retroativo. Cada "não, faz diferente" é uma restrição que deveria estar no prompt original. Você acaba gastando mais tempo corrigindo o agente do que gastaria escrevendo um bom prompt de cara.

É como aquele dev que nunca lê o RFC e fica perguntando no Slack. Funciona - mas custa caro.

## O caminho inverso também funciona

Aqui tem um insight que eu não esperava: escrever prompts bons me fez escrever RFCs melhores.

Quando você precisa ser explícito o suficiente para uma máquina entender, você descobre todas as ambiguidades que um humano preencheria com suposições. E suposições são bugs disfarçados.

Aquela frase que parece clara pra você - "usar a autenticação padrão" - um agente não sabe o que é "padrão". E sabe o que? Tem uma boa chance de que aquele dev junior que entrou semana passada também não sabe.

A disciplina de escrever para agentes melhora sua escrita para humanos.

## O que vem por aí

Este é o primeiro artigo de uma série de dez. Nos próximos, vamos aprofundar cada elemento dessa ponte entre RFCs e prompts:

1. **Este artigo** - A conexão fundamental
2. **Anatomia de um bom RFC** - Os elementos estruturais que funcionam
3. **Anatomia de um bom prompt de sistema** - O espelho do RFC
4. **Restrições explícitas** - O poder do "não faça"
5. **Interfaces e contratos** - Como agentes respeitam fronteiras
6. **Critérios de aceite** - Quando o agente sabe que terminou
7. **Loops de feedback** - Onde o prompt vai além do RFC
8. **Contexto compartilhado** - O que RFCs assumem e agentes precisam ouvir
9. **O documento único** - Escrevendo para humanos e agentes ao mesmo tempo
10. **O futuro da especificação** - Quando o RFC é o código

Cada artigo segue o mesmo padrão: um princípio de RFC, por que funciona para humanos, o equivalente em prompt, um exemplo prático, e o anti-padrão pra você evitar.

---

Se você já escreve bons design docs, você está mais perto de dominar agentes de IA do que imagina. E se você nunca escreveu um RFC na vida, essa série vai te ensinar uma habilidade que funciona nos dois mundos.

Na próxima semana, a gente disseca a anatomia de um bom RFC - peça por peça.

Tem dúvidas ou quer trocar ideia sobre o tema? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
