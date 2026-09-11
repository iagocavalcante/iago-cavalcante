%{
  title: "Do Build à Loja: Automatizando a Publicação de Apps com Computer Use, Codex e Claude",
  author: "Iago Cavalcante",
  tags: ~w(ai mobile codex claude computer-use automacao app-store deploy),
  description: "Como combinar terminal, automação de navegador e computer use para preparar releases, preencher metadados e enviar apps para revisão, com exemplos de sessões reais e sem expor dados sensíveis.",
  locale: "pt_BR",
  published: true
}
---

Fala, pessoal!

O build passou. O app abriu no simulador. Os testes estão verdes.

Aí você abre o painel da loja e começa outra jornada: escolher a versão, conferir screenshots, preencher descrição, atualizar os idiomas e descobrir qual campo está impedindo o envio.

Nas minhas sessões com agentes, essa parte também entrou no fluxo de automação. Em uma delas, o agente operou o App Store Connect pelo navegador, atualizou textos em quatro idiomas e enviou a versão para revisão.

O resultado registrado naquela sessão era **enviado para revisão**. A aprovação da Apple ainda estava pendente.

Quero mostrar como organizar esse processo com Codex ou Claude. Os exemplos abaixo foram generalizados: sem nomes dos projetos, identificadores de conta, credenciais ou dados de usuários.

## Onde entra o computer use

Computer use permite que o agente observe a interface e interaja com ela: clicar, digitar, rolar e conferir o resultado. A disponibilidade e a configuração dependem do produto e do ambiente usados.

No ecossistema do Codex, consulte a [documentação oficial da OpenAI sobre Computer Use](https://learn.chatgpt.com/docs/computer-use). No Claude, existem caminhos como [computer use no Cowork](https://support.claude.com/en/articles/14128542-let-claude-use-your-computer-in-cowork) e a [ferramenta de computer use via API](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool). No caminho da API, sua aplicação precisa executar as ações pedidas pelo modelo e devolver os resultados.

Só escrever “use meu computador” num chat sem essas ferramentas não conecta o agente ao desktop.

Também existe uma diferença útil: automação de navegador pode operar elementos da página diretamente. Computer use pode trabalhar pela interface visual. Nas sessões que consultei, o envio está registrado como automação de navegador; isso não prova que cada clique aconteceu por reconhecimento de screenshot.

Para montar o workflow, eu combinaria as ferramentas assim:

| Etapa | Caminho preferido |
| --- | --- |
| Testes, versão e build | Comandos do projeto e CI |
| Assinatura e upload | Ferramentas oficiais ou integração já configurada |
| Metadados e navegação no painel | API ou automação de navegador, quando disponíveis |
| Interações que exigem interface visual | Computer use |
| Conferência do resultado | Status da loja e evidências da execução |

Se o projeto já tem um comando confiável para gerar o build, o agente pode usá-lo. Não precisa abrir menus para repetir o que já está resolvido.

## Comece definindo o que significa “subir”

Essa palavra esconde várias tarefas diferentes.

Você pode querer enviar um binário, disponibilizar uma versão para testes, submeter para revisão ou liberar uma atualização ao público.

Na Apple, o build enviado ainda precisa ser processado antes de aparecer no App Store Connect. Depois, existe a etapa de selecionar o build e submeter a versão. A documentação separa [upload de builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds) e [envio para revisão](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app).

Por isso, eu começaria com um pedido assim:

```text
Prepare a próxima versão iOS para revisão.

Use o commit e a versão definidos no documento de release.
Execute as verificações existentes no projeto.
Gere e envie o build usando o fluxo já configurado.
Confira o processamento e prepare os metadados no App Store Connect.

Antes da submissão, mostre:
- versão e build selecionados;
- textos e screenshots que serão enviados;
- pendências encontradas;
- configuração de liberação após aprovação.

Pare nesse ponto para minha revisão.
Não altere preços, contratos ou declarações sem informação validada.
Não exiba credenciais nos logs ou na resposta.
```

Esse é um prompt sugerido, não uma transcrição das sessões.

Ele dá ao agente um destino verificável e define até onde vai a autorização daquela execução.

## Prepare o material antes de abrir o painel

Eu manteria um documento pequeno de release no repositório, com versão, referência do código, idiomas, notas da atualização e caminhos dos screenshots aprovados.

As credenciais ficam no mecanismo seguro já utilizado pelo projeto. O documento só precisa indicar qual configuração usar, sem copiar valores.

Faça o login e o segundo fator pelo fluxo normal da ferramenta. Se a sessão expirar, retome a autenticação; não transforme senha ou código temporário em instrução persistente.

Também vale usar dados fictícios nas capturas. Antes de compartilhar uma evidência, confira se ela mostra e-mail, identificador de conta, notificações ou qualquer informação privada.

Parece bobeira, mas preparar isso evita que o agente improvise conteúdo enquanto preenche a loja.

## Observe, preencha, salve e confira

O loop que eu usaria no painel é pequeno:

```text
observar a página atual
  -> confirmar app, versão e idioma
  -> preencher uma seção
  -> salvar
  -> verificar erros e conteúdo persistido
  -> seguir para a próxima seção
```

Quando houver elementos identificáveis na página, prefira esses elementos. Se a interação depender de coordenadas, observe a tela novamente depois de uma mudança de layout.

Um botão clicado não prova que o formulário foi salvo.

Na sessão com quatro idiomas, havia trabalho real de metadados para repetir. Esse é um bom candidato à automação: o agente pode percorrer cada idioma e conferir se o texto correspondente ficou no lugar certo.

Outro registro mostrou dificuldade ao salvar uma descrição com determinada formatação durante a automação. A lição é verificar o erro e o texto persistido. Um incidente desses não basta para afirmar que a loja proíbe aquele caractere em qualquer contexto.

## A revisão também pode revelar um problema no produto

Em outra sessão, uma rejeição apontava que uma integração do app não estava identificável na interface.

O trabalho envolveu tornar essa funcionalidade visível, ajustar o comportamento, adicionar testes e preparar outro build.

Isso muda o próximo passo da automação. Se a loja aponta um problema no aplicativo, repetir o envio não resolve. O agente precisa conectar o feedback ao código, reproduzir o cenário e validar a correção antes de preparar outra submissão.

É a continuação do fluxo que descrevi no artigo sobre QA no simulador: usar evidência para orientar a próxima ação.

## Termine com um status que você consegue conferir

Depois de revisar o material, você pode autorizar o envio daquela versão específica. O agente então executa a submissão e consulta o resultado.

Eu pediria um fechamento neste formato:

```text
Exemplo de relatório:

Build: processado e selecionado
Metadados: conferidos nos idiomas previstos
Submissão: enviada
Status observado: Waiting for Review
Liberação: manual após aprovação
Pendência: avaliação da loja
```

Na Apple, “Waiting for Review” significa que a submissão foi recebida e a revisão ainda não começou. Esse estado está descrito na [referência de status do App Store Connect](https://developer.apple.com/help/app-store-connect/reference/app-information/app-and-submission-statuses).

No Android, dá para aplicar a mesma organização, respeitando o fluxo do Play Console: preparar o bundle, escolher a faixa de testes ou produção e verificar as etapas de revisão e publicação. É uma adaptação sugerida aqui; o exemplo de submissão confirmado nos registros foi no iOS. O Google documenta essas etapas em [preparar e lançar uma versão](https://support.google.com/googleplay/android-developer/answer/9859348?hl=pt-BR).

## Transforme o que funcionou em instrução reutilizável

Depois de executar esse caminho, registre os comandos que funcionaram, onde estão os materiais e quais estados precisam ser conferidos. Pode ser no `AGENTS.md`, no `CLAUDE.md` ou numa skill do projeto.

Não precisa construir uma plataforma de release. Um roteiro claro, as ferramentas já configuradas e a conferência de cada etapa são um bom começo.

O ganho prático é tirar da sua cabeça aquela sequência de abrir painel, procurar campo, trocar idioma e conferir build. Você passa a revisar um resultado concreto, com as pendências visíveis.

Eu começaria automatizando uma atualização até o ponto de revisão humana. Depois de validar esse caminho, ampliaria o escopo conforme a necessidade.

Bora testar?
