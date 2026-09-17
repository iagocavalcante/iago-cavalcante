%{
  title: "O que é o Jev (e por que eu comecei a usar)",
  author: "Iago Cavalcante",
  tags: ~w(ai llm typesafe jev claude-code telegram),
  description: "O Jev, da TypeSafe, não gera texto. Ele devolve uma decisão tipada com probabilidade. Veja como eu troquei regex e prompt gigante por ele no claude_notify e no MiseSnag.",
  locale: "pt_BR",
  published: true
}
---

Fala, pessoal!

Todo mundo que já botou LLM em produção conhece esse ritual:

1. Escreve um prompt enorme.
2. Pede pro modelo "responder SÓ com JSON".
3. Reza pra ele não inventar um campo.
4. Faz o parse, trata o erro e torce pro resultado ser o mesmo na próxima vez.

Funciona, mas é usar um canhão pra matar mosquito. Na maioria das vezes eu não quero que a IA escreva nada. Eu quero que ela decida uma coisinha só.

O Jev é um modelo da TypeSafe feito exatamente pra isso. Ele não gera texto. Você manda um contexto e uma pergunta com as respostas possíveis, e ele devolve uma resposta tipada com probabilidade.

## Pensa assim

Um LLM tradicional é tipo um amigo que fala demais. Você pergunta "a receita tá na legenda?" e ele te devolve um parágrafo.

O Jev é tipo um amigo objetivo: "Sim, 97% de certeza." Pronto. Aí quem decide o que fazer com isso é o seu código.

## Os três tipos de pergunta

Com o Jev você só faz três tipos de pergunta:

- **Noul** (sim ou não): "Essa legenda tem ingredientes suficientes pra montar uma lista de compras?" → `0.97`.
- **Choice** (escolha uma opção): "Onde tá a receita?" → `comments`, com 100% de confiança.
- **Score** (nota numa escala): "Quão urgente é essa mensagem?" → uma posição na escala que você mesmo definiu.

Pra montar uma pergunta você manda três coisas:

1. **O estado**, ou seja, o contexto: a legenda, a mensagem, o que for.
2. **A instrução**, que é a pergunta em si.
3. **Os critérios**, que dizem o que significa cada resposta.

## Exemplo real: o claude_notify

No meu bot do Telegram que controla o Claude Code, quando ele pede permissão pra rodar um comando, antes eu só entendia `y`, `yes` ou `1`. Se eu respondesse "sim, pode rodar", o bot não entendia e digitava o texto inteiro no terminal.

Agora o Jev interpreta a resposta:

- **"sim, pode rodar"** → aprovar (`1.0`). O bot aperta o Yes.
- **"pode, mas não mexe nas migrations"** → aprovar com instrução. O bot **NÃO** aperta o botão, porque ia perder a condição que eu coloquei.
- **"por que precisa de rm -rf?"** → pergunta. Manda o texto pro Claude.

E repara que eu nunca configurei português. Ele simplesmente entendeu.

## Exemplo real: o MiseSnag

No MiseSnag eu decidia com regex se a legenda do vídeo já tinha a receita. Se tem, eu pulo o download e a transcrição, que é onde tá o custo. Testei 6 legendas:

- **A regex errou 2.** Não reconheceu uma lista de ingredientes sem quantidades e achou que "Ingredients: see video!" era uma receita.
- **O Jev acertou as 6.** E de brinde ainda disse onde tava a receita: nos comentários, na tela ou falada.

Cada erro da regex custa dinheiro: download, Whisper, chamada de LLM à toa.

## O que eu mais gosto

1. **O código continua no controle.** O Jev dá a opinião e o código decide. Eu é que defino: "só aperta o botão se tiver 90% de certeza". Se tiver abaixo disso, faço o comportamento antigo, que é seguro.
2. **É rápido.** Mais ou menos 0,9s por chamada, e dá pra mandar várias perguntas na mesma requisição.
3. **Não tem parse de JSON frágil.** A resposta já vem no formato certo.
4. **A probabilidade vira regra de negócio.** Dá pra ajustar os limites de confiança sem mexer em prompt nenhum.

## Onde NÃO usar

Se você precisa gerar texto (escrever uma receita, traduzir, resumir), aí é LLM mesmo. O Jev é pra julgamento: classificar, rotear, verificar, escolher entre opções.

A regra que eu tô seguindo:

> **LLM pra escrever. Jev pra decidir. Código pra executar.**

Menos prompt gigante, menos parse quebrando e mais decisão previsível.

É isso, pessoal! Se testar o Jev em algum projeto, me conta como foi no [Twitter](https://x.com/iagoangelimc) ou no [LinkedIn](https://linkedin.com/in/iago-a-cavalcante).
