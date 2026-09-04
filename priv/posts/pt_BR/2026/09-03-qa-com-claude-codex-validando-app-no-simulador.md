%{
  title: "Seu Próximo QA Pode Ser um Agente: Validando Apps no Simulador com Claude ou Codex",
  author: "Iago Cavalcante",
  tags: ~w(ai qa testes mobile claude codex mcp simuladores automacao),
  description: "Como conectar Claude ou Codex ao simulador, transformar requisitos em cenários executáveis e criar um loop de QA mobile com evidências, logs e testes de regressão.",
  locale: "pt_BR",
  published: false
}
---

Fala, pessoal!

Sabe quando você termina uma feature mobile, roda os testes, vê tudo verde e mesmo assim abre o app para conferir “só mais uma vez”?

Você faz login. Toca em três botões. Volta uma tela. Troca o idioma. Fecha e abre o app. Ativa o modo avião. Quando percebe, passou meia hora repetindo um roteiro que está só na sua cabeça.

Foi aí que comecei a olhar para Claude e Codex de outro jeito.

Em vez de usar o agente apenas para escrever código, por que não dar a ele acesso ao simulador e pedir para validar o app como um QA faria?

Não estou falando de mandar um prompt como “teste meu app” e confiar num “parece tudo certo”. A parte interessante é montar um loop em que o agente consegue:

1. Compilar e abrir o aplicativo
2. Ler a árvore de acessibilidade da tela
3. Tocar, digitar, rolar e navegar
4. Capturar screenshots e logs
5. Comparar o resultado com critérios de aceite
6. Corrigir o problema e repetir exatamente o mesmo fluxo

Isso muda bastante a dinâmica do desenvolvimento. O agente deixa de ser apenas quem implementa e passa a ser também quem tenta provar que a implementação funciona.

Neste artigo vou mostrar uma estratégia genérica para fazer isso. Serve para apps nativos, React Native, Flutter ou qualquer stack que consiga rodar em um iOS Simulator ou Android Emulator.

## O Problema Não É a Falta de Testes

Quase todo projeto mobile tem algum nível de teste automatizado.

Temos unit tests para regras de negócio, integration tests para API e, em alguns casos, testes end-to-end com Maestro, Detox ou Appium.

Mesmo assim, vários bugs continuam escapando:

- um botão ficou escondido pelo teclado
- a sessão sumiu depois de reiniciar o app
- o loading não termina quando a API falha
- o texto em português quebra o layout
- o botão de voltar abre a tela errada
- a permissão foi negada e o app não explica como continuar
- a feature funciona isolada, mas falha no fluxo real do usuário

Isso acontece porque existe um espaço entre “o código passou nos testes” e “uma pessoa conseguiu usar o app”.

O QA no simulador ajuda a fechar esse espaço. E um coding agent é particularmente útil porque consegue observar os dois lados ao mesmo tempo: a interface que falhou e o código que produziu aquela interface.

## O Agente Precisa de Olhos, Mãos e Memória

Claude ou Codex, sozinhos, não controlam magicamente seu aplicativo. Eles precisam de ferramentas.

Podemos pensar em três camadas:

```text
Claude ou Codex
      |
      | prompt + critérios de aceite
      v
MCP, skill ou comandos de terminal
      |
      | build, snapshot, tap, type, swipe, logs
      v
iOS Simulator ou Android Emulator
```

No iOS, um MCP como o XcodeBuildMCP pode expor build, launch, screenshots, UI hierarchy, logs e debugger para o agente. A própria OpenAI possui um [caso de uso do Codex no iOS Simulator](https://learn.chatgpt.com/use-cases/ios-simulator-bug-debugging) seguindo esse fluxo.

No Claude Code, o [Model Context Protocol](https://docs.anthropic.com/en/docs/mcp) permite conectar ferramentas externas ao agente. Essa ferramenta pode ser um MCP pronto ou um servidor pequeno do seu time que encapsula os comandos usados no projeto.

No Android, a mesma ideia pode ser construída em cima de `adb`, UI Automator, Maestro ou outro driver que consiga inspecionar e controlar o emulator.

O nome da ferramenta importa menos do que o contrato. O agente precisa conseguir realizar um conjunto pequeno de operações de forma confiável:

```text
build_app
boot_device
install_app
launch_app
read_ui_tree
tap_element
type_text
swipe
take_screenshot
read_logs
reset_app_state
```

Parece bobeira, mas essa lista já é suficiente para validar boa parte de um app.

## Não Comece com “Teste Tudo”

O pior prompt possível é este:

```text
Teste todo o meu aplicativo e corrija qualquer problema.
```

O agente não sabe o que “todo” significa. Também não sabe quais dados pode criar, qual conta deve usar, quais telas são críticas ou quando uma diferença visual é realmente um bug.

Um bom run de QA começa com um cenário, um estado inicial e um resultado esperado.

Por exemplo:

```text
Valide o fluxo de recuperação de senha no iPhone 16 com iOS 26.

Pré-condições:
- use a conta qa@example.com
- comece com o app sem sessão
- não envie e-mails reais

Critérios de aceite:
- um e-mail inválido mostra erro no próprio campo
- um e-mail válido abre a tela de confirmação
- voltar para o login preserva o e-mail digitado
- nenhum erro inesperado aparece nos logs

Entregue:
- passos executados
- screenshots dos estados importantes
- resultado de cada critério
- logs relacionados a qualquer falha
- arquivos alterados, caso uma correção seja necessária
```

Agora existe um contrato verificável.

O agente sabe onde começar, o que pode fazer e qual evidência precisa entregar.

## O Loop Que Eu Uso

Um fluxo confiável de QA com agente possui seis etapas.

### 1. Preparar um Estado Conhecido

Antes de testar, o agente precisa saber se deve limpar o aplicativo, manter uma sessão ou carregar uma fixture.

Sem isso, o mesmo cenário pode passar numa execução e falhar na próxima apenas porque o simulador guardou dados antigos.

Algumas opções úteis:

- desinstalar e instalar o app novamente
- limpar storage e keychain de teste
- usar contas exclusivas de QA
- resetar o banco local
- iniciar uma API fake com respostas conhecidas
- abrir o app por um deep link específico

O ponto não é sempre apagar tudo. É tornar o estado inicial explícito.

### 2. Confirmar a Tela Antes de Interagir

O agente deve capturar um screenshot ou ler a árvore de UI antes do primeiro toque.

Isso evita um erro comum: tentar tocar em um botão usando coordenadas que pertenciam à tela anterior.

Sempre que a interface mudar, o agente lê a hierarquia novamente.

Também vale muito a pena adicionar `accessibilityLabel`, `accessibilityIdentifier`, `testID` ou o equivalente da sua stack nos elementos importantes. Coordenadas quebram quando muda o tamanho do aparelho. Identificadores semânticos sobrevivem.

### 3. Executar Uma Ação por Vez

O agente toca, observa o resultado e só então continua.

```text
ler tela
  -> tocar em “Entrar”
  -> ler nova tela
  -> preencher e-mail
  -> ler estado do formulário
  -> enviar
  -> capturar resultado
```

Essa cadência parece mais lenta, mas economiza tempo quando alguma coisa falha. Você sabe exatamente qual ação mudou o estado.

### 4. Coletar Evidência Enquanto o Bug Acontece

Screenshot ajuda, mas nem todo bug é visual.

Um bom run pode combinar:

- screenshot antes e depois
- árvore de acessibilidade
- logs do aplicativo
- requests e responses da API de teste
- stack trace de crash
- estado persistido no device
- vídeo curto do fluxo, quando fizer sentido

O objetivo é sair de “deu erro” para “deu erro depois desta ação, neste estado, com este log”.

### 5. Fazer a Menor Correção Possível

Se o agente também pode editar o projeto, ele deve primeiro reproduzir a falha e só depois mexer no código.

Essa ordem faz toda diferença.

Sem reprodução, ele pode corrigir uma hipótese. Com reprodução, ele consegue comparar antes e depois.

Também peço para manter o escopo pequeno: um bug por execução. Misturar login, notificações, layout e cache no mesmo run torna difícil saber qual mudança resolveu qual problema.

### 6. Repetir o Mesmo Caminho

Depois da correção, não basta compilar.

O agente deve resetar o estado necessário e repetir o roteiro que falhou. Mesma conta. Mesmo aparelho. Mesmos passos. Mesmos critérios de aceite.

No final, quero uma resposta parecida com esta:

```text
Device: iPhone 16, iOS 26.0
Build: a1b2c3d
Scenario: recuperação de senha

PASS - e-mail inválido mostra erro inline
PASS - e-mail válido abre confirmação
PASS - voltar preserva o e-mail
PASS - nenhum erro inesperado nos logs

Evidence:
- artifacts/password-invalid.png
- artifacts/password-confirmation.png
- artifacts/simulator.log
```

Agora temos evidência, não só confiança.

## Monte uma Matriz Pequena e Útil

Validar todas as combinações de device, sistema operacional e estado é inviável. O segredo é escolher uma matriz que represente risco real.

Eu começaria assim:

| Área | Cenário mínimo |
| --- | --- |
| Onboarding | primeira abertura, pular e concluir |
| Autenticação | login válido, erro e logout |
| Fluxo principal | caminho que entrega o valor central do app |
| Persistência | fechar, reabrir e recuperar o estado |
| Permissões | permitir, negar e tentar novamente |
| Rede | offline, timeout e resposta inválida |
| Layout | aparelho pequeno, fonte maior e outro idioma |
| Navegação | back, deep link e retorno do background |

Não precisa executar tudo em todo commit.

O happy path crítico pode rodar sempre. Cenários de erro e matriz visual podem rodar antes de release ou quando a área correspondente mudar.

## Transforme Descobertas em Regressão

Aqui está a parte que mais gosto desse fluxo.

O agente é bom em exploração. Ele consegue olhar a tela, interpretar um estado estranho e decidir qual caminho tentar depois.

Mas não devemos gastar raciocínio de LLM para sempre repetir o mesmo login.

Quando um cenário estabiliza, transforme-o em um teste determinístico com a ferramenta de E2E do projeto.

```text
agente explora
  -> encontra bug
  -> reproduz com evidência
  -> corrige
  -> escreve teste de regressão
  -> CI repete sem LLM
```

O agente descobre. O teste automatizado protege.

Essa divisão deixa o custo previsível e reduz flakiness. Também evita transformar Claude ou Codex num robô caro clicando sempre nas mesmas telas.

## Coloque as Regras no Repositório

Se toda sessão precisa reaprender como testar seu app, você ainda tem um processo manual.

Documente as regras em `AGENTS.md`, `CLAUDE.md` ou numa skill do projeto.

Um exemplo simples:

```markdown
## QA mobile

- Use sempre a conta qa@example.com.
- Nunca rode fluxos destrutivos em produção.
- Prefira accessibility IDs; não use coordenadas quando existir um seletor.
- Salve evidências em artifacts/qa/<cenario>/.
- Registre device, OS, build e estado inicial.
- Reproduza o bug antes de alterar código.
- Depois da correção, repita o mesmo fluxo.
- Um cenário por execução.
```

Você pode ir além e criar comandos como:

```text
./scripts/qa/reset-app
./scripts/qa/start-fixtures
./scripts/qa/collect-logs
./scripts/qa/run-critical-path
```

Quanto mais fácil for preparar e observar o ambiente, melhor o agente trabalha.

Isso não beneficia só a IA. Uma pessoa nova no time também consegue reproduzir o cenário sem depender de conhecimento tribal.

## Onde o Simulador Não É Suficiente

Tem mais, mas existe um limite importante: simulador não é aparelho real.

Eu não usaria esse fluxo como única validação para:

- push notification entregue por APNs ou FCM
- câmera, microfone, Bluetooth e NFC
- biometria real
- consumo de bateria e memória
- performance em aparelhos de entrada
- comportamento com rede móvel instável
- compra e assinatura nas lojas
- background execution controlado pelo sistema
- diferenças de fabricante no Android

O simulador cobre muito bem navegação, estados, formulários, layout, persistência e vários erros de integração. Para capacidades físicas ou comportamento específico do sistema, ainda precisamos de canário em device real.

Também não eliminaria revisão humana. O agente consegue provar que um botão funciona, mas não decide sozinho se a experiência é clara, agradável ou coerente com o produto.

## O Resultado Prático

Quando esse loop funciona, você não ganha um “QA artificial” que substitui uma pessoa.

Você ganha uma forma barata de tirar trabalho repetitivo da cabeça do time.

O desenvolvedor descreve o comportamento esperado. O agente prepara o simulador, executa o fluxo, coleta evidência e aponta onde o contrato quebrou. Se puder corrigir, faz a menor mudança e repete o mesmo caminho.

Depois, o cenário importante vira regressão determinística.

É uma composição simples:

```text
unit tests garantem regras
integration tests garantem contratos
E2E garante fluxos conhecidos
agente explora o que ainda não virou teste
device real valida o que o simulador não representa
```

Nenhuma camada resolve tudo. Juntas, elas deixam o release muito menos dependente daquele “abre aí rapidinho e vê se está funcionando”.

É isso, pessoal!

Se você já conectou Claude ou Codex ao simulador, me conta como montou seu loop. Me chama no [Twitter](https://x.com/iagoangelimc) ou no [LinkedIn](https://linkedin.com/in/iago-a-cavalcante).

Bora testar?
