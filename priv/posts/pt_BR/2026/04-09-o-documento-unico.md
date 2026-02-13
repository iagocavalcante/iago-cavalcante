%{
  title: "O Documento Único: Escrevendo para Humanos e Agentes ao Mesmo Tempo",
  author: "Iago Cavalcante",
  tags: ~w(ia engenharia-de-software rfcs prompts agentes desenvolvimento),
  description: "Um único documento que funciona como RFC para engenheiros e como prompt para agentes. Não é compromisso - é a versão melhor dos dois.",
  locale: "pt_BR",
  published: false,
  scheduled_for: ~D[2026-04-09]
}
---

Fala, pessoal! Nove artigos. Duas trilhas paralelas. Hoje elas se encontram.

Desde o primeiro artigo, a gente caminhou por dois mundos que pareciam separados. De um lado, RFCs -- documentos que alinham equipes humanas há décadas. Do outro, prompts -- instruções que guiam agentes de IA. E artigo após artigo, uma coisa ficou evidente: as melhores práticas de um são as melhores práticas do outro.

Estrutura clara. Restrições explícitas. Interfaces definidas. Critérios de aceite verificáveis. Feedback loops. Contexto compartilhado. Tudo que faz um RFC funcionar para engenheiros faz um prompt funcionar para agentes. A ponte existe. Agora é hora de cruzar ela de vez.

## Dois documentos, um problema

Na prática, o que acontece na maioria dos times que trabalham com agentes? Eles mantêm dois artefatos separados.

O RFC vai pro time de engenharia. Descreve o problema, a solução, as decisões arquiteturais, o que está fora do escopo. É escrito em prosa, assume contexto compartilhado, e serve como registro de decisão.

O prompt vai pro agente. Repete boa parte do que está no RFC, mas adiciona detalhes técnicos que o RFC "não precisa": stack exata, caminhos de arquivo, exemplos de código, formato de saída esperado.

Resultado? Dois documentos que dizem quase a mesma coisa, mas com divergências sutis. O RFC diz "usar autenticação padrão do projeto." O prompt diz "usar phx_gen_auth com Argon2." Quando alguém atualiza o RFC mas esquece de atualizar o prompt, o agente implementa algo diferente do que o time decidiu. Quando alguém ajusta o prompt mas não reflete no RFC, o documento de referência fica desatualizado.

Dois documentos = duas fontes de verdade = nenhuma fonte de verdade.

## A fusão que ninguém esperava

E se existisse um único documento que servisse para os dois? Que um engenheiro sênior pudesse ler e entender a proposta completa, e que um agente de IA pudesse receber e executar?

Parece compromisso. Parece que você vai ter que simplificar um lado pra atender o outro. Mas não é isso que acontece.

Ao longo desta série, eu fui percebendo algo que mudou minha forma de escrever documentação técnica: **as informações que um agente precisa são exatamente as que tornam um RFC melhor para humanos.** Não é coincidência. É consequência de um princípio mais profundo.

## O que um agente precisa que um RFC tradicional não tem

Um RFC tradicional funciona porque assume contexto. O leitor sabe qual é a stack. Sabe onde ficam os arquivos. Sabe quais patterns o time usa. Sabe como rodar os testes. O RFC não precisa dizer isso porque o leitor já sabe.

Um agente não sabe nada disso.

Pra funcionar como prompt, o documento precisa de adições que um RFC tradicional omite:

**Declaração explícita de stack.** Não "usar o framework do projeto." Sim "Elixir 1.16, Phoenix 1.7, LiveView, PostgreSQL 16, Tailwind CSS."

**Caminhos de arquivo.** Não "criar o módulo no lugar adequado." Sim "criar `lib/iagocavalcante/bookmarks/bookmark.ex` e `lib/iagocavalcante_web/live/bookmark_live/index.ex`."

**Exemplos de código.** Não "seguir o padrão do projeto." Sim, um trecho de código mostrando como o padrão se aplica a este caso.

**Expectativas de teste executáveis.** Não "deve ter testes." Sim "o teste deve verificar que `Bookmarks.create_bookmark/1` retorna `{:ok, %Bookmark{}}` com atributos válidos."

**Formato de saída.** Não "retornar os dados do bookmark." Sim, o JSON exato ou a struct exata que deve ser retornada.

E aqui vem o ponto crucial: **nenhuma dessas adições prejudica a leitura humana.** Na verdade, elas melhoram.

## Escrever para agentes te faz um escritor melhor para humanos

Lembra do dev junior que entrou no time semana passada? Ele também não sabe qual é "a autenticação padrão do projeto." Ele também não sabe onde "o lugar adequado" fica. Ele também precisa de um exemplo pra entender o pattern.

Quando você escreve um RFC com a precisão que um agente exige, você está escrevendo um RFC que qualquer pessoa do time consegue seguir -- não só as que estavam na reunião de alinhamento, não só as que já conhecem o codebase de cor.

A explicitação que agentes demandam é a mesma que torna documentos acessíveis para:

- Devs juniors que ainda estão aprendendo o projeto
- Devs de outros times que precisam contribuir pontualmente
- Você mesmo, daqui a seis meses, quando esqueceu por que tomou aquela decisão
- Qualquer pessoa fazendo onboarding

O documento unificado não é um compromisso entre dois públicos. É a versão que deveria ter sido escrita desde o início.

## O template do documento unificado

Depois de refinar essa abordagem ao longo de toda a série, cheguei num template que funciona consistentemente para humanos e agentes. Cada seção tem um papel duplo.

```
# [Título da Feature]

## Problema
O que está errado hoje. Por que isso precisa ser resolvido.
Por que agora.

## Contexto
Onde essa feature se encaixa no sistema. Quais decisões
anteriores influenciam esta. Links para RFCs relacionados.

## Stack e ambiente
- Linguagem: Elixir 1.16
- Framework: Phoenix 1.7 com LiveView
- Banco: PostgreSQL 16
- CSS: Tailwind CSS 3.4
- Testes: ExUnit com async: true

## Solução proposta
Descrição da abordagem escolhida. Por que essa e não
outra. Trade-offs aceitos.

## Restrições
- NÃO usar belongs_to entre contexts (usar field :user_id, :id)
- NÃO fazer queries no mount/3 do LiveView
- Sanitizar inputs contra null bytes (usar Sanitizer)
- Tasks assíncronas via Task.Supervisor

## Fora do escopo (non-goals)
- O que este documento NÃO resolve
- Features relacionadas que ficam pra depois
- Decisões adiadas intencionalmente

## Contratos de interface

### Endpoints expostos
GET /api/bookmarks -> lista de bookmarks do usuário
POST /api/bookmarks -> cria novo bookmark
DELETE /api/bookmarks/:id -> soft delete

### Tipos
@type bookmark :: %{
  id: integer(),
  url: String.t(),
  title: String.t(),
  user_id: integer(),
  inserted_at: DateTime.t()
}

### Formato de resposta
Sucesso (200):
{"data": [bookmark]}

Erro (422):
{"error": "validation_failed", "details": [...]}

## Critérios de aceite
- [ ] Usuário pode adicionar bookmark com URL e título
- [ ] URL validada (deve começar com http:// ou https://)
- [ ] URLs duplicadas por usuário retornam erro claro
- [ ] Título limitado a 200 caracteres
- [ ] Soft delete com confirmação
- [ ] Lista paginada, 20 por página, mais recente primeiro
- [ ] Usuário só vê seus próprios bookmarks

## Estrutura de arquivos
lib/
  iagocavalcante/
    bookmarks/
      bookmark.ex          # Schema + changesets
      bookmarks.ex         # Context (CRUD)
  iagocavalcante_web/
    live/
      bookmark_live/
        index.ex           # LiveView principal
        form_component.ex  # Componente de formulário
test/
  iagocavalcante/
    bookmarks_test.exs     # Testes do context
  iagocavalcante_web/
    live/
      bookmark_live_test.exs  # Testes do LiveView

## Exemplos

### Schema
defmodule Iagocavalcante.Bookmarks.Bookmark do
  use Ecto.Schema

  schema "bookmarks" do
    field :url, :string
    field :title, :string
    field :user_id, :id
    field :deleted_at, :utc_datetime

    timestamps()
  end
end

### Context
defmodule Iagocavalcante.Bookmarks do
  def list_bookmarks(user_id) do
    Bookmark
    |> where(user_id: ^user_id)
    |> where([b], is_nil(b.deleted_at))
    |> order_by(desc: :inserted_at)
    |> Repo.paginate()
  end
end
```

Olha pra esse template. Agora tenta separar o que é "pro humano" e o que é "pro agente." Não dá. Tudo é útil para os dois. O problema é útil para o humano entender a motivação e para o agente entender o contexto. Os critérios de aceite são o definition of done do time e o sinal de parada do agente. Os exemplos de código são referência para o dev e instrução para o agente.

## O documento único na prática: sistema de bookmarks

Pra mostrar que isso não é teoria, vou usar o exemplo que a gente visitou ao longo de vários artigos -- um sistema de bookmarks. Repare como cada seção do template se preenche naturalmente.

O **Problema** diz por que precisamos de bookmarks: usuários pedem uma forma de salvar conteúdo para ler depois. O **Contexto** diz que já temos um sistema de autenticação e um dashboard onde os bookmarks vão aparecer. A **Stack** elimina qualquer ambiguidade sobre tecnologias. As **Restrições** reforçam padrões do projeto que o artigo 4 nos ensinou a explicitar. Os **Contratos** definem a interface antes da implementação, como vimos no artigo 5. Os **Critérios de aceite** são o sinal de parada do artigo 6. A **Estrutura de arquivos** diz exatamente onde cada coisa vai. Os **Exemplos** mostram o padrão esperado, não deixando margem pra interpretação.

Um engenheiro lê isso e sabe o que construir, por que, e como validar que terminou.

Um agente lê isso e tem toda a informação necessária para executar.

Um documento. Dois públicos. Zero compromisso.

## A vantagem de manutenção

Além da qualidade do documento em si, o modelo unificado resolve um problema operacional que poucos mencionam: **manutenção.**

Com dois documentos separados (RFC + prompt), qualquer mudança precisa ser refletida em dois lugares. "Decidimos mudar de soft delete para hard delete" -- atualiza o RFC, atualiza o prompt. "O endpoint mudou de /api/bookmarks para /api/v2/bookmarks" -- atualiza os dois. "Adicionamos um novo critério de aceite" -- atualiza os dois.

Na prática, a segunda atualização quase sempre atrasa ou é esquecida. E quando os dois documentos divergem, nenhum dos dois é confiável.

Com o documento unificado, a mudança acontece em um lugar. O engenheiro que atualiza o RFC está automaticamente atualizando o prompt. O prompt que o agente recebe é sempre a versão mais recente da decisão do time. Uma fonte de verdade. Sempre sincronizada.

## O mapa da série, revisitado

Ao longo dos oito artigos anteriores, cada peça se encaixou:

O artigo 1 mostrou que RFCs e prompts resolvem o mesmo problema -- comunicar intenção com clareza. O artigo 2 dissecou a estrutura do RFC. O artigo 3 fez o espelho no prompt. O artigo 4 ensinou a explicitar restrições. O artigo 5 definiu contratos de interface. O artigo 6 criou critérios de aceite verificáveis. O artigo 7 foi além do RFC com feedback loops. O artigo 8 trouxe o contexto que agentes precisam ouvir explicitamente.

Este artigo, o nono, é a síntese. Cada um daqueles elementos tem um lugar no documento unificado. Não é uma mistura forçada -- é o encaixe natural de peças que sempre foram parte do mesmo quebra-cabeça.

## O que vem por aí

No décimo e último artigo, a gente olha pra frente. O que acontece quando o documento unificado evolui de um artefato estático para algo que se integra diretamente ao código? Quando o RFC não descreve o sistema -- ele **é** o sistema? Vamos falar sobre o futuro da especificação técnica.

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
9. **O documento único** *(este artigo)*
10. O futuro da especificação *(em breve)*

---

Curtiu? Quer trocar ideia sobre como unificar seus documentos técnicos? Me encontra no [Twitter](https://x.com/iagoangelimc) ou [LinkedIn](https://linkedin.com/in/iagocavalcante).
