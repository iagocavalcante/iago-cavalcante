%{
  title: "Construindo um Servidor de Minecraft em Elixir: Fundação Técnica e Módulos Centrais",
  author: "Iago Cavalcante",
  tags: ~w(elixir otp minecraft bedrock java nif protocolos arquitetura),
  description: "Uma análise profunda da arquitetura de um servidor de Minecraft em Elixir, com Java e Bedrock, processos OTP, RakNet, codecs binários, geração de mundo em C e persistência por mutações.",
  locale: "pt_BR",
  published: true
}
---

Fala, pessoal!

Nos últimos dias eu voltei para um projeto que sempre achei divertido: implementar um servidor de Minecraft em Elixir.

Não é um plugin. Não é uma automação em cima de Paper ou Spigot. É o servidor mesmo, começando no socket, lendo bytes do cliente, entendendo o protocolo, gerando chunks e mantendo o estado do mundo.

Parece uma ideia meio maluca, e talvez seja. Mas também é um projeto muito bom para estudar protocolos binários, concorrência, isolamento de falhas, state machines, interoperabilidade com C e, claro, OTP.

O servidor já aceita clientes Java Edition 1.12.2 e Bedrock Edition 1.26.x. No Bedrock, um celular real consegue entrar, renderizar o terreno, caminhar por um mundo que continua sendo gerado, quebrar blocos, colocar blocos e abrir o inventário criativo.

Neste artigo eu quero ir além do “funciona”. Quero mostrar a fundação técnica que permite isso acontecer, os módulos centrais, como os dados atravessam o sistema e quais decisões tornaram possível compartilhar o mesmo mundo entre duas edições do Minecraft que falam protocolos completamente diferentes.

O código está disponível no [GitHub](https://github.com/iagocavalcante/minecraft).

## Antes de Tudo: O Que um Servidor de Minecraft Precisa Fazer?

Quando você abre o Minecraft e adiciona um servidor, parece que o fluxo é simples:

1. O cliente encontra o servidor
2. Faz login
3. Recebe o mundo
4. Começa a jogar

Só que cada linha dessa lista esconde várias camadas.

No Java Edition, a conexão chega por TCP na porta `25565`. O servidor precisa entender o framing dos pacotes, decodificar `VarInt`, negociar criptografia, validar o login, enviar os pacotes iniciais e manter a conexão viva.

No Bedrock Edition, a conexão chega por UDP na porta `19132`. Antes de falar de jogador, chunk ou inventário, o servidor precisa implementar RakNet, com descoberta, handshake, MTU, índices de confiabilidade, ordenação, fragmentação, ACK e NAK.

Depois disso ainda existe o protocolo de jogo do Bedrock, que tem seu próprio login, compressão, resource packs, registries, estados de spawn e formatos de chunk.

Em outras palavras, o servidor não recebe “o jogador colocou um bloco”. Ele recebe bytes. Nosso trabalho é transformar esses bytes em uma ação de domínio segura, atualizar o mundo e depois converter o resultado novamente em bytes.

Essa ideia guia toda a arquitetura:

```text
socket
  -> transporte
  -> frame
  -> pacote
  -> ação de domínio
  -> estado do mundo
  -> pacote de resposta
  -> frame
  -> socket
```

Cada etapa tem uma responsabilidade específica. Misturar tudo em um único processo até funcionaria no primeiro teste, mas ficaria impossível evoluir o servidor sem quebrar alguma coisa.

## A Visão Geral: Duas Portas, Um Mundo

A decisão mais importante foi tratar Java e Bedrock como adapters de protocolo em volta de um domínio compartilhado.

```text
                         Minecraft.Application
                                  |
                    Minecraft.Supervisor (:one_for_one)
                                  |
          +-----------------------+-----------------------+
          |                       |                       |
    Minecraft.World        Minecraft.Users        Minecraft.Crypto
          |
          | estado compartilhado do mundo
          |
    +-----+-----------------------------+
    |                                   |
Java Edition                        Bedrock Edition
TCP :25565                          UDP :19132
Ranch                               :gen_udp + RakNet
Minecraft.Protocol                  Minecraft.Bedrock.Session
Minecraft.Connection                Minecraft.Bedrock.Packet
Minecraft.StateMachine              Minecraft.Bedrock.Chunk
```

O lado Java sabe falar Java. O lado Bedrock sabe falar Bedrock. O módulo `Minecraft.World` não precisa conhecer nenhum dos dois protocolos.

Internamente, o mundo usa o formato de bloco do Java 1.12 como representação canônica. Quando um cliente Bedrock solicita um chunk, `Minecraft.Bedrock.Chunk` traduz essa representação para network block hashes. Quando o cliente quebra um bloco, a sessão Bedrock chama a mesma função `Minecraft.World.set_block/4` que qualquer outro adapter pode usar.

Isso parece um detalhe de implementação, mas faz toda diferença. Sem uma representação interna única, teríamos dois mundos, duas caches e duas fontes de verdade tentando permanecer sincronizadas.

## `Minecraft.Application`: Onde a Topologia Começa

O ponto de entrada é uma aplicação OTP normal:

```elixir
def start(_type, _args) do
  children = [
    Minecraft.Crypto,
    Minecraft.World,
    Minecraft.Users,
    Minecraft.Server,
    Minecraft.Bedrock.SessionSupervisor,
    Minecraft.Bedrock.Listener
  ]

  opts = [strategy: :one_for_one, name: Minecraft.Supervisor]
  Supervisor.start_link(children, opts)
end
```

Tem uma característica do Elixir que combina muito bem com um game server: a arquitetura do sistema aparece na árvore de processos.

Não precisamos imaginar quem é dono de cada estado. A topologia deixa isso explícito.

`Minecraft.World` é dono dos chunks e das mutações. `Minecraft.Users` mantém o registro de jogadores Java. `Minecraft.Crypto` mantém o material usado no login Java. Os listeners recebem conexões, mas não concentram a lógica de cada jogador.

Com `:one_for_one`, uma falha isolada reinicia apenas o filho afetado. As sessões Bedrock também são processos temporários sob um `DynamicSupervisor`, então o encerramento de um cliente não derruba o listener nem outras sessões.

Isso é mais do que organização. É uma política de falhas.

## A Entrada Java: Ranch e Um Processo por Conexão

O `Minecraft.Server` abre a porta TCP usando Ranch. Ele é pequeno de propósito. Sua responsabilidade é aceitar conexões e entregar cada socket para um novo `Minecraft.Protocol`.

O fluxo fica assim:

```text
Ranch aceita TCP
  -> inicia Minecraft.Protocol
  -> cria Minecraft.Connection
  -> recebe bytes do socket
  -> Minecraft.Packet decodifica
  -> Minecraft.Protocol.Handler trata o pacote
  -> Minecraft.Connection é atualizado
```

### `Minecraft.Protocol`: O Dono do Socket

Cada cliente Java tem um `Minecraft.Protocol`, implementado como `GenServer`.

Esse processo possui o socket, mantém a struct da conexão, acumula dados parciais e controla quando o próximo pacote pode entrar. O socket usa o modo `active: :once`, então entrega uma mensagem por vez para o processo.

Depois que aquela mensagem é tratada, o servidor reativa o socket.

Parece bobeira, mas isso evita que um cliente rápido encha a mailbox do processo enquanto ele ainda está decodificando pacotes anteriores. É uma forma simples de backpressure.

TCP também não respeita a nossa ideia de pacote. Uma leitura pode trazer metade de um pacote ou vários pacotes juntos. Por isso `Minecraft.Protocol` mantém um buffer e chama repetidamente `Connection.read_packet/1` enquanto houver dados completos.

### `Minecraft.Connection`: Estado Imutável no Estilo Plug

O estado lógico da conexão não fica espalhado em variáveis. Ele é representado por `%Minecraft.Connection{}`.

A struct guarda informações como:

- estado atual do protocolo
- socket e transport
- dados ainda não consumidos
- encryptor e decryptor
- username e UUID
- configurações enviadas pelo cliente
- referência para a state machine de gameplay

As transformações seguem um estilo parecido com Plug:

```elixir
conn =
  conn
  |> Connection.encrypt(shared_secret)
  |> Connection.verify_login()
  |> Connection.put_state(:play)
  |> Connection.join()
```

Esse formato ajuda bastante no raciocínio. Cada função recebe uma conexão e devolve uma nova conexão. O processo continua sendo dono do estado, mas as regras que transformam esse estado ficam fáceis de testar e combinar.

### `Minecraft.Packet`: Bytes Entrando, Structs Saindo

O protocolo Java usa vários formatos binários que aparecem em praticamente todos os pacotes:

- `VarInt`
- strings prefixadas pelo tamanho
- posições compactadas em 64 bits
- enums e flags
- framing com o tamanho total do pacote

O módulo `Minecraft.Packet` concentra esses codecs e faz o dispatch para módulos específicos.

Cada pacote possui uma struct e duas operações principais:

```elixir
serialize(packet)   # struct -> {packet_id, binary}
deserialize(data)  # binary -> {struct, rest}
```

Por exemplo, o pacote de chat não precisa saber nada sobre sockets. Ele sabe apenas transformar sua representação Elixir no formato esperado pelo protocolo.

Essa separação permite testar round trips de serialização sem iniciar o servidor inteiro.

### `Minecraft.Protocol.Handler`: Dispatch Sem Estado Próprio

Depois que um pacote vira struct, o `Minecraft.Protocol.Handler` decide o que ele significa.

Um `Handshake` muda o estado para `:status` ou `:login`. Um `LoginStart` prepara a negociação de criptografia. Um `PlayerPositionAndLook` atualiza posição e rotação. Um `ChatMessage` cria a resposta que será enviada ao cliente.

O handler não possui processo próprio. Ele recebe o pacote e a conexão atual, então devolve uma resposta junto da nova conexão.

```text
binary
  -> %Client.Play.ChatMessage{}
  -> Handler.handle/2
  -> %Server.Play.ChatMessage{}
  -> binary
```

O ganho aqui é manter I/O, parsing e regra de protocolo em camadas diferentes.

### `Minecraft.StateMachine`: Entrar, Spawnar, Manter Vivo

Quando o login termina, `Minecraft.Protocol` inicia uma `Minecraft.StateMachine` usando `:gen_statem`.

Ela possui três estados principais:

```text
:join -> :spawn -> :ready
```

No `:join`, o servidor registra o usuário e envia informações iniciais como `JoinGame`, posição de spawn, horário, abilities, inventário e teleport.

No `:spawn`, calcula um raio limitado pela view distance do cliente e envia chunks em anéis ao redor da origem. A ordem em anéis faz o terreno mais próximo chegar primeiro.

No `:ready`, envia keep-alives e encerra a conexão se o cliente deixar de responder por 30 segundos.

State machine é uma escolha muito melhor do que um conjunto crescente de booleanos como `logged_in?`, `spawned?` e `ready?`. Estados inválidos ficam mais difíceis de representar e cada transição ganha um lugar claro no código.

## A Entrada Bedrock: UDP Não É Só um TCP Mais Rápido

No Bedrock, a história muda bastante.

O protocolo usa UDP, então não temos uma conexão pronta entregue pelo sistema operacional. É o RakNet que cria sobre UDP conceitos como sessão, confiabilidade, ordenação, fragmentação e confirmação de entrega.

Esse lado do servidor é dividido em módulos menores:

```text
Minecraft.Bedrock.Listener
Minecraft.Bedrock.SessionSupervisor
Minecraft.Bedrock.Session
Minecraft.Bedrock.RakNet
Minecraft.Bedrock.RakNet.Frame
Minecraft.Bedrock.RakNet.FrameSet
Minecraft.Bedrock.Codec
Minecraft.Bedrock.Packet
Minecraft.Bedrock.Chunk
Minecraft.Bedrock.Items
```

### `Minecraft.Bedrock.Listener`: Um Socket, Muitas Sessões

O listener abre um socket com `:gen_udp` e recebe datagramas de todos os clientes.

Antes de existir uma sessão, ele responde aos pacotes offline do RakNet:

1. `UnconnectedPing`, usado na descoberta do servidor
2. `OpenConnectionRequest1`, usado para negociar versão e MTU
3. `OpenConnectionRequest2`, que conclui a fase offline

Depois do segundo request, o listener cria uma `Minecraft.Bedrock.Session` e associa o par `{ip, porta}` ao PID daquela sessão.

A partir daí, novos datagramas daquele cliente são encaminhados para o processo correto:

```elixir
send(pid, {:raknet_data, data})
```

O listener monitora os PIDs. Quando uma sessão termina, recebe `:DOWN` e remove a associação. Dessa forma, o processo que roteia UDP não precisa conhecer inventário, posição ou chunks enviados para cada jogador.

### `RakNet`, `Frame` e `FrameSet`: Reconstruindo Confiabilidade

O módulo `Minecraft.Bedrock.RakNet` trata a parte offline e os endereços codificados pelo protocolo. `FrameSet` trabalha com datagramas numerados, ACKs e NAKs. `Frame` representa cada unidade interna com seus índices de confiabilidade e ordenação.

Os números de sequência do RakNet têm 24 bits em little-endian. Frames grandes podem ser divididos e carregam `count`, `id` e `index` para remontagem.

Na entrada, a sessão faz basicamente isto:

```text
datagrama UDP
  -> FrameSet.decode/1
  -> envia ACK da sequência
  -> decodifica frames
  -> junta fragments pelo split_id
  -> entrega payload completo ao protocolo Bedrock
```

Na saída, o tamanho máximo depende do MTU negociado. Se um batch ultrapassar esse limite, `send_reliable_fragmented/2` divide o payload, incrementa os índices e envia vários frame sets.

Ainda existem peças importantes para uma implementação robusta de RakNet, principalmente retransmissão ao receber NAK e enforcement completo dos canais ordenados. O servidor atual reconhece esses pacotes e mantém os índices, mas essa é uma das áreas que precisam de mais trabalho antes de chamar o projeto de production-ready.

É importante falar disso porque protocolo de rede quase nunca fica pronto quando o happy path funciona.

### `Minecraft.Bedrock.Session`: Estado de Rede e Estado de Jogo

Cada cliente Bedrock possui seu próprio `GenServer`. A struct da sessão guarda:

- índices de envio, confiabilidade e ordenação
- fragments aguardando remontagem
- estado atual do handshake
- nome do jogador
- posição e rotação
- raio e centro de chunks
- conjunto de chunks já enviados
- estado do inventário

O fluxo de entrada é uma state machine explícita:

```text
:connecting
  -> :pre_login
  -> :logging_in
  -> :resource_packs
  -> :starting
  -> :spawning
  -> :playing
```

Na prática, um celular só entra no mundo depois desta sequência:

1. Handshake conectado do RakNet
2. `RequestNetworkSettings`
3. Ativação da compressão
4. `Login`
5. Negociação de resource packs
6. `StartGame`
7. Registro de itens e inventário criativo
8. Envio dos chunks iniciais
9. `PlayStatus(PlayerSpawn)`
10. Confirmação de inicialização do jogador

A ordem importa. Enviar `PlayerSpawn` antes dos chunks, omitir o item registry ou abrir duas vezes o mesmo container pode produzir desde um mundo vazio até um crash no cliente.

Foi uma das partes mais interessantes do projeto. Muitas vezes o formato do pacote estava correto, mas o momento estava errado.

### `Minecraft.Bedrock.Codec` e `Packet`: O Protocolo de Jogo

Depois do RakNet, pacotes de jogo são agrupados em batches identificados por `0xFE`. Esses batches podem usar compressão e carregar vários pacotes, cada um prefixado pelo próprio tamanho.

`Minecraft.Bedrock.Codec` cuida do batch. `Minecraft.Bedrock.Packet` conhece os campos de cada pacote.

Essa divisão é parecida com a do lado Java, mas existe uma camada extra:

```text
UDP
  -> RakNet FrameSet
  -> RakNet Frame
  -> Bedrock batch
  -> Bedrock packet
  -> ação do jogo
```

Separar essas camadas foi essencial para debugar. Quando o cliente desconecta, conseguimos descobrir se o problema está no datagrama, no frame, na compressão, no tamanho do pacote ou na semântica da sequência.

## `Minecraft.World`: Uma Fonte de Verdade Compartilhada

Java e Bedrock chegam por caminhos diferentes, mas ambos terminam no mesmo `Minecraft.World`.

Esse módulo é um `GenServer` responsável por:

- inicializar a seed
- manter chunks carregados em memória
- gerar um chunk quando ele é solicitado pela primeira vez
- serializar alterações de bloco
- carregar mutações persistidas
- executar autosave

A API pública é pequena:

```elixir
Minecraft.World.get_chunk(chunk_x, chunk_z)
Minecraft.World.set_block(x, y, z, type)
Minecraft.World.save()
```

Uma API pequena é uma qualidade importante aqui. O restante do servidor não precisa conhecer a estrutura interna da cache ou do recurso NIF.

### Coordenadas Globais e Coordenadas Locais

Um chunk possui 16 blocos no eixo X e 16 no eixo Z. Para alterar um bloco, precisamos descobrir o chunk responsável e a posição dentro dele.

```elixir
chunk_x = Integer.floor_div(x, 16)
chunk_z = Integer.floor_div(z, 16)
local_x = Integer.mod(x, 16)
local_z = Integer.mod(z, 16)
```

Usar `floor_div` e `mod` aqui é importante. Divisão truncada costuma funcionar no lado positivo e falhar quando o jogador atravessa a coordenada zero. No chunk `-1`, por exemplo, o bloco global `x = -1` precisa virar `local_x = 15`, não `-1`.

Esse tipo de bug só aparece quando você anda para o lado “errado” do mapa. Um teste com coordenadas negativas vale mais do que dez testes felizes na origem.

### Por Que Todas as Escritas Passam Pelo Mesmo Processo?

O chunk é um recurso alocado em C. Alterá-lo diretamente de várias sessões abriria espaço para writes concorrentes e estado difícil de reproduzir.

Por isso toda mutação passa por `Minecraft.World.set_block/4`. O mailbox do `GenServer` serializa as operações.

```text
Sessão A quebra bloco ----+
                          +-> Minecraft.World -> NIF.set_block/5
Sessão B coloca bloco ----+
```

O modelo é simples: muitos leitores, um caminho de escrita.

No estágio atual, sessões podem ler os tipos de bloco para codificar chunks enquanto o processo do mundo escreve um `uint16_t` alinhado. Elas podem observar o valor anterior ou o novo, mas não um valor parcialmente escrito nas arquiteturas alvo. Para uma versão mais robusta, snapshots imutáveis ou versionamento por chunk seriam evoluções naturais.

## Persistência: Salvar a Diferença, Não o Mundo Inteiro

O chunk mantido pelo Elixir não é um mapa comum. Ele contém uma referência para um recurso NIF opaco, gerenciado pelo runtime da BEAM e alocado em C.

Tentar gravar esse recurso diretamente com `term_to_binary/1` não representa o conteúdo real do chunk. Mesmo que fosse possível guardar o termo, aquele ponteiro não teria significado depois que o processo reiniciasse.

A solução foi aproveitar uma propriedade do mundo: o terreno base é determinístico.

Com a mesma seed e as mesmas coordenadas, o gerador produz o mesmo chunk. Então não precisamos persistir milhões de blocos que nunca mudaram. Precisamos guardar apenas as alterações feitas pelos jogadores.

```text
chunk final = terreno(seed, x, z) + mutações persistidas
```

Para cada chunk, o storage mantém um mapa parecido com este:

```elixir
%{
  {1, 72, 3} => 16,
  {15, 80, 0} => 0
}
```

A chave é `{local_x, y, local_z}`. O valor é o tipo interno do bloco. Colocar ar também é uma mutação, porque representa um bloco removido do terreno original.

Quando um chunk é carregado:

1. O NIF regenera o terreno base
2. O storage procura o arquivo daquele chunk
3. As mutações válidas são reaplicadas
4. O chunk entra na cache

Quando um jogador altera um bloco, o mundo marca aquele chunk como dirty. A cada 30 segundos, apenas chunks dirty são gravados.

### Escrita Atômica

Salvar diretamente no arquivo final cria um risco. Se o processo morrer no meio da escrita, o arquivo pode ficar pela metade.

O storage usa outro fluxo:

```text
serializa termo versionado
  -> escreve arquivo temporário com :sync
  -> renomeia para o caminho final
```

O rename no mesmo filesystem funciona como o ponto atômico da troca. O leitor vê a versão anterior ou a nova, não um arquivo intermediário parcialmente escrito.

O formato também possui versão:

```elixir
%{version: 1, blocks: mutations}
```

Isso deixa espaço para migrations no futuro. Parece uma preocupação prematura até o primeiro save incompatível aparecer depois de um deploy.

No Docker, `/data/world` é um volume. Sem isso, recriar o container apagaria as alterações mesmo com toda a persistência funcionando corretamente dentro dele.

## A Camada C: Onde o Mundo Nasce

Elixir é ótimo para coordenar processos, conexões e estado. Geração e serialização de milhares de blocos é um tipo diferente de trabalho.

O projeto usa NIFs em C para a parte pesada:

```text
src/perlin.c   -> ruído e octaves
src/biome.c    -> distribuição de biomas
src/chunk.c    -> blocos, luz e serialização Java
src/nifs.c     -> ponte entre BEAM e C
```

### Recurso NIF e Ciclo de Vida

Um chunk é alocado com `enif_alloc_resource`. O Elixir recebe um termo que referencia esse recurso, mas não manipula o ponteiro diretamente.

Quando o termo deixa de ser alcançável, o garbage collector da BEAM chama o destructor registrado pelo NIF. O destructor libera heightmap, biomas e todas as seções alocadas.

Isso cria uma ponte segura entre dois modelos de memória:

```text
%Minecraft.Chunk{resource: nif_resource}
                         |
                         v
               struct Chunk em C
```

As funções mais custosas, como `generate_chunk/2` e `serialize_chunk/1`, são registradas com `ERL_NIF_DIRTY_JOB_CPU_BOUND`. Assim, a geração não bloqueia um scheduler normal da BEAM por um período longo.

Esse detalhe é fundamental. Um NIF rápido pode rodar no scheduler normal. Um NIF pesado que não cede controle pode congelar latências de todo o sistema.

### Heightmap com Perlin Noise

Para cada coluna X/Z do chunk, o gerador calcula uma altura usando seis octaves de Perlin noise.

Cada octave aumenta a frequência e reduz a amplitude. As primeiras definem grandes formas do terreno. As seguintes adicionam detalhes menores.

```text
altura = octave_perlin(x, y, z, 6, 0.4) * 125
```

Depois, `generate_chunk_section` decide o bloco de cada posição:

- bedrock nas camadas inferiores
- stone abaixo da superfície
- dirt próximo da superfície
- grass no topo
- sand em regiões baixas
- water até o nível 64
- air acima do terreno
- tall grass em algumas posições

O PRNG usado para inicializar as tabelas é o `splitmix64`. Isso evita depender de `rand()` da libc, que pode produzir sequências diferentes entre plataformas. A mesma seed precisa gerar o mesmo mundo no notebook, no servidor e dentro do Docker, principalmente porque a persistência depende dessa propriedade.

### Biomas com Voronoi

O heightmap define a forma do terreno. O biome map define que tipo de região cada coluna representa.

O gerador divide o mundo em zonas, cria pontos determinísticos em zonas vizinhas e escolhe o ponto mais próximo de cada coordenada. Na prática, é uma distribuição baseada em Voronoi.

Os biomas atuais incluem ocean, plains, desert, forest, taiga, swamp, ice plains, jungle e birch forest.

Mesmo que a vegetação ainda não use toda essa informação, enviar biomas reais muda cor da água, grama, folhagem e percepção do mundo no cliente.

## Um Chunk, Dois Formatos de Rede

Aqui está uma das partes que mais gosto nessa arquitetura.

O chunk em memória é compartilhado. A serialização não.

O Java 1.12 espera seções com seus IDs globais, bit packing de 13 bits, block light, sky light, heightmap e biomas no formato daquela versão.

O Bedrock 1.26 espera subchunks v9, storages paletizados, hashes de network block IDs, biome storage e outros metadados.

Então o fluxo é:

```text
                      struct Chunk em C
                              |
             +----------------+----------------+
             |                                 |
      serializer Java                 Minecraft.Bedrock.Chunk
      protocolo 340                   protocolo 1001
             |                                 |
       ChunkData TCP                    LevelChunk UDP
```

`Minecraft.Bedrock.Chunk` lê as seções como um binary de 4096 valores `uint16_t`, converte cada tipo Java para o nome canônico do bloco Bedrock e calcula seu network hash.

O servidor ativa `UseBlockNetworkIDHashes`. Com isso, não precisa manter uma tabela gigantesca de runtime IDs específica para cada build. Ele calcula hashes FNV-1a a partir dos estados normalizados do bloco.

Também existe o caminho inverso. Quando o cliente informa o hash do bloco segurado, o adapter procura o tipo interno correspondente. Assim, selecionar um bloco no inventário criativo realmente influencia o bloco colocado no mundo.

Esse é o papel de uma boa boundary: o domínio não aprende detalhes do protocolo, e o adapter não cria uma segunda fonte de verdade.

## Do Movimento à Geração Infinita

No Bedrock, o cliente envia `PlayerAuthInput` várias vezes por segundo. A sessão atualiza posição e rotação, trata ações de bloco e verifica se o jogador atravessou a fronteira de um chunk.

```elixir
center = {floor(px / 16), floor(pz / 16)}
```

Se o centro mudou, a sessão envia primeiro um `NetworkChunkPublisherUpdate`. Depois calcula quais chunks estão dentro do raio e ainda não foram enviados para aquele cliente.

Cada sessão mantém um `MapSet` chamado `sent_chunks`. Isso evita retransmitir o mesmo chunk a cada movimento.

Para cada chunk novo:

1. `Minecraft.World.get_chunk/2` busca ou gera
2. `Minecraft.Bedrock.Chunk.encode/1` converte para Bedrock
3. `Packet.encode_level_chunk/4` monta o pacote
4. O codec comprime o batch
5. RakNet fragmenta se ultrapassar o MTU
6. O listener envia por UDP

É uma cadeia longa, mas cada passo pode ser testado separadamente.

## Quebrar um Bloco Atravessa o Sistema Inteiro

Uma ação simples mostra como os módulos trabalham juntos.

Quando o jogador quebra um bloco no Bedrock:

```text
PlayerAuthInput
  -> Bedrock.Packet.decode
  -> Bedrock.Session.handle_break_block
  -> World.set_block(x, y, z, air)
  -> NIF.set_block no recurso C
  -> registra mutação e marca chunk dirty
  -> UpdateBlock para o cliente
  -> autosave em arquivo atômico
```

Cada camada responde uma pergunta:

- O pacote está bem formado?
- A ação é suportada?
- A coordenada é válida?
- Qual chunk possui esse bloco?
- Como o estado em C deve mudar?
- Como confirmar a mudança no protocolo do cliente?
- Como recuperar essa mudança depois de um restart?

Se tudo isso estivesse dentro de `handle_info({:udp, ...})`, adicionar multiplayer seria um pesadelo.

## Testes: Bytes Antes da Interface

Testar um servidor de jogo apenas abrindo o cliente é lento e pouco determinístico.

O projeto usa três níveis de teste.

### 1. Testes Puros de Codec

VarInts, frames, frame sets, ACKs, NAKs e packets possuem testes de encode/decode. Esses testes encontram problemas de endianness e tamanhos incorretos sem iniciar sockets.

### 2. Testes de Integração em Elixir

Um cliente TCP de teste percorre o handshake Java, status, ping, login criptografado e pacotes iniciais de jogo.

O world storage também possui um teste de restart. Ele altera blocos, salva, encerra o processo, inicia outro mundo e verifica os valores dentro do recurso NIF. O caso usa coordenadas negativas para proteger exatamente a conversão entre posição global e local.

### 3. Cliente Bedrock Headless

Scripts baseados em `bedrock-protocol` conectam como cliente Bedrock real. Um valida a sequência completa de spawn. Outro quebra e coloca blocos, então espera as confirmações do servidor.

O celular continua sendo necessário para validar comportamento visual e crashes específicos do cliente. Mas ele virou o último estágio, não o primeiro.

## O Que Esta Fundação Já Permite

Hoje, a arquitetura suporta:

- Java Edition 1.12.2 por TCP
- Bedrock Edition 1.26.x por UDP e RakNet
- mundo compartilhado entre as duas edições
- terreno determinístico com Perlin noise
- biomas distribuídos por Voronoi
- streaming de chunks conforme o jogador caminha
- quebra e colocação de blocos no Bedrock
- inventário criativo e item registry
- persistência de mutações com autosave
- build de release em Docker

Mas ainda existem limitações importantes:

- mudanças de bloco ainda precisam ser broadcast para todas as sessões
- jogadores Bedrock ainda não enxergam outros jogadores
- NAK ainda não dispara retransmissão
- canais ordenados precisam de enforcement completo
- sessões Bedrock precisam de timeout próprio
- cache de chunks cresce sem política de eviction
- gameplay de survival ainda é muito básico
- inventário precisa de estado autoritativo no servidor

Uma boa fundação não elimina o trabalho seguinte. Ela faz o trabalho seguinte caber em módulos claros.

## Os Próximos Módulos Que Fazem Sentido

O próximo passo natural é multiplayer real.

Em vez de cada sessão confirmar uma mudança apenas para o cliente que a originou, `Minecraft.World` pode publicar eventos como:

```elixir
{:block_changed, %{x: x, y: y, z: z, type: type, source: player_id}}
```

Adapters Java e Bedrock assinariam esses eventos e converteriam a mesma mudança para seus respectivos pacotes.

Depois, o mesmo padrão pode servir para:

- entrada e saída de jogadores
- movimento
- chat
- spawn de entidades
- horário do mundo
- dano e vida

Também quero separar a confiabilidade RakNet em um processo ou módulo com janela de envio, buffer de frames não confirmados e timers de retransmissão. Hoje a sessão mistura estado de transporte e estado de gameplay porque isso acelerou o primeiro cliente funcional. A arquitetura já mostra onde essa divisão deve acontecer.

Essa é uma lição prática que vale para outros projetos: primeiro encontre as boundaries reais. Depois refine o interior delas.

## O Que Eu Aprendi Construindo Isso

Algumas coisas ficaram muito claras durante o desenvolvimento.

### Protocolos São Mais Sobre Sequência do Que Sobre Structs

Ter todos os campos corretos não garante que o cliente aceite o pacote. No Bedrock, ordem, compressão ativa, estado atual e pacotes anteriores fazem parte do contrato.

### OTP Funciona Muito Bem Quando Existe Estado Concorrente

Listeners, sessões, mundo e registries têm ciclos de vida diferentes. Processos deixam esses limites visíveis e supervisores transformam falhas em decisões locais.

### Uma Representação Interna Evita Duplicação de Domínio

Java e Bedrock discordam sobre IDs, framing e transporte. Eles não precisam discordar sobre qual bloco existe na coordenada `{10, 70, -4}`.

### NIF É Uma Ferramenta Cirúrgica

Não faria sentido escrever toda a rede em C. Também não faria sentido transformar milhões de operações de bloco em mensagens Elixir individuais. O NIF fica exatamente na parte onde memória compacta e loops numéricos importam.

### Persistência Pode Explorar Determinismo

Salvar apenas mutações reduziu o problema porque o terreno base pode ser reconstruído. Às vezes o melhor formato de persistência não é um snapshot completo. É a menor informação necessária para recompor o estado.

## Rodando o Projeto

Para executar nativamente, você precisa de Elixir, Erlang/OTP e um compilador C:

```bash
mix deps.get
mix run --no-halt
```

Com Docker:

```bash
docker build -t minecraft:local .

docker run -d \
  --name minecraft \
  --restart unless-stopped \
  -v minecraft-world:/data/world \
  -p 25565:25565/tcp \
  -p 19132:19132/udp \
  minecraft:local
```

Depois, no Bedrock, basta adicionar o IP da máquina com a porta `19132`.

## O Ponto Principal

Construir um servidor de Minecraft do zero não é só implementar pacotes até o cliente parar de desconectar.

O desafio real é criar uma arquitetura onde transporte, protocolo, sessão, domínio, geração e persistência possam evoluir sem virar a mesma coisa.

Elixir e OTP cuidam muito bem da coordenação. C cuida dos loops pesados e da representação compacta dos chunks. Os adapters Java e Bedrock traduzem dois mundos de protocolo para uma única fonte de verdade.

Ainda tem bastante coisa para construir, mas agora cada próxima feature tem um lugar natural para existir. E isso, para mim, é o sinal de uma fundação técnica boa.

Tem dúvidas, quer contribuir ou já tentou implementar algum protocolo de jogo? Me encontra no [Twitter](https://x.com/iagoangelimc) ou no [LinkedIn](https://linkedin.com/in/iago-a-cavalcante).

É isso, pessoal! Bora testar?
