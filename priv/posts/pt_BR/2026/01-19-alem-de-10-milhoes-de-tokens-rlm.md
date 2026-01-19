%{
  title: "Além de 10 Milhões de Tokens: O Verdadeiro Avanço em Memória de LLMs É Sobre Complexidade, Não Tamanho",
  author: "Iago Cavalcante",
  tags: ~w(ia llm rlm memoria contexto pesquisa),
  description: "O problema real não é o tamanho da janela de contexto - é como o modelo interage com a informação. Recursive Language Models propõem uma mudança de paradigma que pode redefinir o que LLMs conseguem fazer.",
  locale: "pt_BR",
  published: true
}
---

Fala, pessoal! Sabe quando você joga um documento gigante num LLM e ele simplesmente ignora detalhes importantes do começo? Ou quando você tem uma conversa longa e o modelo "esquece" o que vocês combinaram lá atrás?

Isso tem nome: "context rot" (degradação de contexto). E é frustrante demais.

Mesmo modelos de ponta como GPT-5 sofrem com isso. A performance cai conforme o contexto aumenta - e cai mais rápido ainda quando a tarefa é complexa. Essa memória limitada é o principal gargalo que impede LLMs de resolver problemas realmente grandes, tipo analisar uma codebase inteira ou um corpus massivo de pesquisa.

Mas e se a solução não fosse simplesmente construir uma memória maior, e sim mudar fundamentalmente como o LLM interage com a informação?

Um paper recente, "Recursive Language Models", propõe exatamente isso. E o resultado é impressionante.

## 1. A Grande Sacada: Parar de Ler e Começar a Programar

O insight central por trás dos RLMs (Recursive Language Models) é parar de tratar prompts longos como um texto único pra ser lido de uma vez. Em vez disso, o RLM trata o prompt como um **ambiente externo** que o LLM pode manipular simbolicamente.

Funciona assim: o RLM carrega o prompt inteiro num ambiente de programação (um REPL - Read-Eval-Print Loop) como uma variável. Aí o LLM é instruído a escrever código. Com esse código, ele pode "espiar", decompor e analisar pequenos trechos do prompt gigante. E o mais interessante: ele pode chamar a si mesmo recursivamente nesses pedaços menores pra resolver sub-tarefas.

Na prática, isso ensina o LLM a tratar seu próprio contexto não como uma memória pra relembrar, mas como um **banco de dados pra ser consultado e manipulado**.

O paper usa uma analogia com algoritmos "out-of-core" de processamento de dados - onde sistemas com memória pequena e rápida conseguem processar datasets enormes gerenciando inteligentemente como os dados são buscados de um armazenamento mais lento. O RLM faz a mesma coisa: usa sua janela de contexto fixa como uma memória principal pequena e rápida pra operar sobre um prompt externo praticamente ilimitado.

## 2. Os Ganhos de Performance São Absurdos

Os resultados são dramáticos. A pesquisa mostra que RLMs conseguem lidar com inputs de até **duas ordens de magnitude além** da janela de contexto do modelo base.

O exemplo mais impressionante vem da tarefa OOLONG-Pairs - um benchmark projetado pra testar raciocínio sobre **pares** de dados num input grande. Nessa tarefa:

| Modelo | Score |
|--------|-------|
| GPT-5 (padrão) | < 0.1% |
| GPT-5 + RLM | **58.00%** F1 |

Isso não é só uma melhoria - é uma **capacidade emergente**. O modelo ganhou uma habilidade que simplesmente não tinha antes.

## 3. É Contra-Intuitivamente Mais Barato (Na Maioria das Vezes)

Apesar do processo complexo de escrever código e fazer chamadas recursivas, os RLMs têm "custos de token comparáveis ou mais baratos" que modelos padrão. Pro GPT-5, o estudo descobriu que "a mediana de uma execução RLM é mais barata que a mediana do modelo base".

O motivo é simples: um LLM padrão precisa ingerir o contexto inteiro, não importa o tamanho. Um RLM, por outro lado, pode **inteligentemente e seletivamente** ver apenas as partes mais relevantes do contexto. Ele não precisa "ler" o livro inteiro se consegue usar código pra pular direto pro capítulo certo.

**Mas tem um porém importante:** os custos do RLM têm uma cauda longa, com alta variância. Enquanto a mediana é mais barata, algumas execuções outliers podem ser "significativamente mais caras" devido a trajetórias de raciocínio longas e complexas.

## 4. O Verdadeiro Inimigo Não É Tamanho, É Complexidade

Essa foi a descoberta que mais me chamou atenção.

O paper argumenta que a "janela de contexto efetiva" de um LLM não é um número fixo de tokens. Ela **encolhe** conforme a complexidade da tarefa aumenta.

Pra entender isso, os pesquisadores caracterizaram tarefas por como sua complexidade escala com o tamanho do prompt:

**Escala Constante:**
Uma tarefa simples de "agulha no palheiro" (S-NIAH) tem complexidade constante. Encontrar uma informação não fica mais difícil conforme o palheiro cresce. Aqui o GPT-5 performa bem.

**Escala Linear:**
Uma tarefa como OOLONG, que requer processar quase toda linha do prompt pra formar uma resposta, tem complexidade linear. A carga de trabalho cresce em proporção direta ao tamanho do input. Aqui a performance do GPT-5 degrada mais rápido.

**Escala Quadrática:**
Uma tarefa como OOLONG-Pairs, que requer comparar **pares** de entradas no dataset, tem complexidade quadrática. A carga de trabalho explode conforme o input cresce. Aqui a performance do GPT-5 colapsa catastroficamente.

| Complexidade | Exemplo | GPT-5 Padrão | GPT-5 + RLM |
|--------------|---------|--------------|-------------|
| Constante | Needle-in-a-Haystack | Bom | Bom |
| Linear | OOLONG | Degrada | Mantém |
| Quadrática | OOLONG-Pairs | Colapsa (<0.1%) | Funciona (58%) |

LLMs padrão são frágeis contra tarefas com complexidade linear e especialmente quadrática. RLMs, embora não imunes, mostram uma taxa de degradação dramaticamente mais lenta. Essa habilidade de manter performance forte contra complexidade quadrática é o verdadeiro avanço.

## 5. O LLM Começa a Se Comportar Como um Pesquisador

Uma das descobertas mais fascinantes é que RLMs exibem padrões sofisticados e "emergentes" de raciocínio e decomposição de problemas - sem serem explicitamente treinados pra isso. O modelo aprende a gerenciar sua própria carga cognitiva, muito parecido com um pesquisador humano.

**Filtragem com Código:**
O modelo usa código, como queries regex, pra buscar palavras-chave e filtrar o contexto massivo. Ele até usa seus próprios priors pra informar essas buscas, como procurar a frase "La Union" numa tarefa relacionada a geografia.

**Chunking Estratégico:**
O modelo aprende a quebrar problemas dividindo o contexto em chunks e chamando recursivamente um sub-modelo em cada pedaço.

**Auto-Verificação:**
Antes de produzir um resultado final, o modelo frequentemente usa chamadas sub-LM com contextos pequenos e focados pra verificar suas próprias respostas.

**Construção de Respostas Longas:**
O modelo consegue produzir outputs "muito além do limite do LM base". Ele faz isso usando variáveis no ambiente REPL pra armazenar resultados de sub-problemas e depois juntando tudo programaticamente numa resposta final abrangente.

## Resumindo: Um Novo Eixo de Escala

Recursive Language Models oferecem um novo paradigma pra escalar IA. Em vez de simplesmente construir modelos maiores com janelas de contexto maiores, RLMs fazem modelos existentes **mais inteligentes** sobre como processam informação. O foco muda de memória bruta pra raciocínio inteligente e procedural.

Essa pesquisa sugere um futuro onde LLMs são treinados não apenas em dados, mas no **processo de raciocínio em si**. Se um modelo pode ser ensinado a ser seu próprio pesquisador, que outras tarefas humanas complexas ele poderia aprender a decompor e resolver por conta própria?

A pergunta que fica: se você pudesse dar a um modelo a capacidade de analisar uma codebase inteira, um corpus de pesquisa completo, ou anos de dados históricos de uma empresa - o que você construiria?

---

**Interessado em IA aplicada e engenharia de software?** Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).

Bora construir!
