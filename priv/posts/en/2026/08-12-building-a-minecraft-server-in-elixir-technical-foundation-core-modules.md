%{
  title: "Building a Minecraft Server in Elixir: Technical Foundation and Core Modules",
  author: "Iago Cavalcante",
  tags: ~w(elixir otp minecraft bedrock java nif protocols architecture),
  description: "A deep look at the architecture of a Minecraft server built in Elixir, covering Java and Bedrock, OTP processes, RakNet, binary codecs, C terrain generation, and mutation-based persistence.",
  locale: "en",
  published: true
}
---

Hey, everyone!

Over the last few days, I returned to a project that I have always found fun: implementing a Minecraft server in Elixir.

It is not a plugin. It is not automation built on top of Paper or Spigot. It is the actual server, starting at the socket, reading bytes from the client, understanding the protocol, generating chunks, and keeping the world state alive.

It sounds a little crazy, and maybe it is. But it is also a great project for studying binary protocols, concurrency, fault isolation, state machines, C interoperability, and, of course, OTP.

The server already accepts Java Edition 1.12.2 and Bedrock Edition 1.26.x clients. On Bedrock, a real phone can join, render the terrain, walk through a world that keeps generating, break blocks, place blocks, and open the creative inventory.

In this article, I want to go beyond “it works.” I want to show the technical foundation that makes it work, the core modules, how data moves through the system, and which decisions made it possible to share one world between two Minecraft editions that speak completely different protocols.

The code is available on [GitHub](https://github.com/iagocavalcante/minecraft).

## First, What Does a Minecraft Server Actually Need to Do?

When you open Minecraft and add a server, the flow looks simple:

1. The client finds the server
2. It logs in
3. It receives the world
4. You start playing

But every line in that list hides several layers.

In Java Edition, the connection arrives over TCP on port `25565`. The server needs to understand packet framing, decode `VarInt`, negotiate encryption, validate the login, send the initial packets, and keep the connection alive.

In Bedrock Edition, the connection arrives over UDP on port `19132`. Before talking about players, chunks, or inventory, the server needs to implement RakNet, including discovery, handshake, MTU negotiation, reliability indexes, ordering, fragmentation, ACK, and NAK.

After that, there is still the Bedrock game protocol, with its own login, compression, resource packs, registries, spawn states, and chunk formats.

In other words, the server does not receive “the player placed a block.” It receives bytes. Our job is to turn those bytes into a safe domain action, update the world, and then convert the result back into bytes.

That idea guides the whole architecture:

```text
socket
  -> transport
  -> frame
  -> packet
  -> domain action
  -> world state
  -> response packet
  -> frame
  -> socket
```

Each step has a specific responsibility. Putting everything inside one process might work for the first test, but evolving the server without breaking it would quickly become painful.

## The Big Picture: Two Doors, One World

The most important decision was to treat Java and Bedrock as protocol adapters around a shared domain.

```text
                         Minecraft.Application
                                  |
                    Minecraft.Supervisor (:one_for_one)
                                  |
          +-----------------------+-----------------------+
          |                       |                       |
    Minecraft.World        Minecraft.Users        Minecraft.Crypto
          |
          | shared world state
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

The Java side knows how to speak Java. The Bedrock side knows how to speak Bedrock. `Minecraft.World` does not need to understand either protocol.

Internally, the world uses the Java 1.12 block format as its canonical representation. When a Bedrock client asks for a chunk, `Minecraft.Bedrock.Chunk` translates that representation into network block hashes. When the client breaks a block, the Bedrock session calls the same `Minecraft.World.set_block/4` function that any other adapter can use.

This may look like a small implementation detail, but it makes all the difference. Without one internal representation, we would have two worlds, two caches, and two sources of truth trying to remain synchronized.

## `Minecraft.Application`: Where the Topology Begins

The entry point is a normal OTP application:

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

There is one Elixir characteristic that fits a game server really well: the process tree makes the system architecture visible.

We do not need to guess who owns each piece of state. The topology makes it explicit.

`Minecraft.World` owns the chunks and mutations. `Minecraft.Users` keeps the Java player registry. `Minecraft.Crypto` owns the material used during Java login. The listeners receive connections, but they do not concentrate the state and logic of every player.

With `:one_for_one`, an isolated failure restarts only the affected child. Bedrock sessions are also temporary processes under a `DynamicSupervisor`, so one client disconnecting does not bring down the listener or other sessions.

This is more than organization. It is a failure policy.

## The Java Entry Point: Ranch and One Process per Connection

`Minecraft.Server` opens the TCP port using Ranch. It is intentionally small. Its responsibility is accepting connections and handing each socket to a new `Minecraft.Protocol` process.

The flow looks like this:

```text
Ranch accepts TCP
  -> starts Minecraft.Protocol
  -> creates Minecraft.Connection
  -> receives bytes from the socket
  -> Minecraft.Packet decodes them
  -> Minecraft.Protocol.Handler handles the packet
  -> Minecraft.Connection is updated
```

### `Minecraft.Protocol`: The Socket Owner

Every Java client gets a `Minecraft.Protocol`, implemented as a `GenServer`.

This process owns the socket, stores the connection struct, accumulates partial data, and controls when the next message can enter. The socket runs in `active: :once` mode, so it delivers one message at a time to the process.

After that message is handled, the server activates the socket again.

It sounds simple, but it prevents a fast client from filling the process mailbox while previous packets are still being decoded. It is a practical form of backpressure.

TCP also does not care about our packet boundaries. One read may contain half a packet or several packets together. Because of that, `Minecraft.Protocol` maintains a buffer and repeatedly calls `Connection.read_packet/1` while complete packets are available.

### `Minecraft.Connection`: Immutable State in a Plug-Like Style

The logical connection state is not scattered across random variables. It is represented by `%Minecraft.Connection{}`.

The struct stores information such as:

- current protocol state
- socket and transport
- data that has not been consumed yet
- encryptor and decryptor
- username and UUID
- settings sent by the client
- a reference to the gameplay state machine

Transformations follow a style similar to Plug:

```elixir
conn =
  conn
  |> Connection.encrypt(shared_secret)
  |> Connection.verify_login()
  |> Connection.put_state(:play)
  |> Connection.join()
```

This shape makes the code easier to reason about. Each function receives a connection and returns a new one. The process still owns the state, but the rules that transform it become easy to test and compose.

### `Minecraft.Packet`: Bytes In, Structs Out

The Java protocol uses binary formats that appear in almost every packet:

- `VarInt`
- length-prefixed strings
- positions packed into 64 bits
- enums and flags
- framing with the total packet size

`Minecraft.Packet` centralizes these codecs and dispatches to specific packet modules.

Each packet has a struct and two main operations:

```elixir
serialize(packet)   # struct -> {packet_id, binary}
deserialize(data)  # binary -> {struct, rest}
```

For example, the chat packet does not need to know anything about sockets. It only knows how to turn its Elixir representation into the format expected by the protocol.

This separation lets us test serialization round trips without starting the entire server.

### `Minecraft.Protocol.Handler`: Dispatch Without Its Own State

Once a packet becomes a struct, `Minecraft.Protocol.Handler` decides what it means.

A `Handshake` changes the connection state to `:status` or `:login`. A `LoginStart` prepares encryption negotiation. A `PlayerPositionAndLook` updates position and rotation. A `ChatMessage` creates the response sent back to the client.

The handler does not own a process. It receives the packet and the current connection, then returns a response with the updated connection.

```text
binary
  -> %Client.Play.ChatMessage{}
  -> Handler.handle/2
  -> %Server.Play.ChatMessage{}
  -> binary
```

The practical benefit is that I/O, parsing, and protocol rules remain separate layers.

### `Minecraft.StateMachine`: Join, Spawn, Stay Alive

When login finishes, `Minecraft.Protocol` starts a `Minecraft.StateMachine` using `:gen_statem`.

It has three main states:

```text
:join -> :spawn -> :ready
```

In `:join`, the server registers the user and sends initial information such as `JoinGame`, spawn position, time, abilities, inventory, and teleport data.

In `:spawn`, it calculates a radius limited by the client view distance and sends chunks in rings around the origin. The ring order lets nearby terrain arrive first.

In `:ready`, it sends keep-alives and closes the connection if the client stops responding for 30 seconds.

A state machine is much better than a growing collection of booleans like `logged_in?`, `spawned?`, and `ready?`. Invalid states become harder to represent, and every transition gets a clear home in the code.

## The Bedrock Entry Point: UDP Is Not Just Faster TCP

On Bedrock, the story changes quite a bit.

The protocol uses UDP, so the operating system does not hand us a ready-to-use connection. RakNet builds concepts such as sessions, reliability, ordering, fragmentation, and delivery confirmation on top of UDP.

This side of the server is split into smaller modules:

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

### `Minecraft.Bedrock.Listener`: One Socket, Many Sessions

The listener opens a socket with `:gen_udp` and receives datagrams from every client.

Before a session exists, it answers RakNet offline packets:

1. `UnconnectedPing`, used for server discovery
2. `OpenConnectionRequest1`, used to negotiate the version and MTU
3. `OpenConnectionRequest2`, which completes the offline phase

After the second request, the listener creates a `Minecraft.Bedrock.Session` and associates the `{ip, port}` pair with that session PID.

From that point on, new datagrams from the client are forwarded to the correct process:

```elixir
send(pid, {:raknet_data, data})
```

The listener monitors each PID. When a session ends, it receives `:DOWN` and removes the association. This means the process routing UDP never needs to understand inventory, position, or which chunks have already been sent to a player.

### `RakNet`, `Frame`, and `FrameSet`: Rebuilding Reliability

`Minecraft.Bedrock.RakNet` handles the offline phase and protocol-specific address encoding. `FrameSet` works with numbered datagrams, ACKs, and NAKs. `Frame` represents each internal unit with reliability and ordering indexes.

RakNet sequence numbers are 24-bit little-endian integers. Large frames may be split and carry `count`, `id`, and `index` values for reassembly.

On incoming traffic, the session basically does this:

```text
UDP datagram
  -> FrameSet.decode/1
  -> acknowledge the sequence
  -> decode frames
  -> combine fragments by split_id
  -> deliver the complete payload to Bedrock protocol handling
```

On outgoing traffic, the maximum body size depends on the negotiated MTU. If a batch crosses that limit, `send_reliable_fragmented/2` splits the payload, increments the indexes, and sends several frame sets.

There are still important pieces required for a robust RakNet implementation, especially retransmission after receiving a NAK and full enforcement of ordered channels. The current server recognizes these packets and maintains the indexes, but this is one area that needs more work before the project can be called production-ready.

This is worth saying because network protocols are almost never finished when the happy path starts working.

### `Minecraft.Bedrock.Session`: Network State and Game State

Every Bedrock client has its own `GenServer`. The session struct stores:

- send, reliability, and ordering indexes
- fragments waiting for reassembly
- current handshake state
- player name
- position and rotation
- chunk radius and center
- the set of chunks already sent
- inventory state

The connection flow is an explicit state machine:

```text
:connecting
  -> :pre_login
  -> :logging_in
  -> :resource_packs
  -> :starting
  -> :spawning
  -> :playing
```

In practice, a phone only enters the world after this sequence:

1. Connected RakNet handshake
2. `RequestNetworkSettings`
3. Compression activation
4. `Login`
5. Resource pack negotiation
6. `StartGame`
7. Item registry and creative inventory
8. Initial chunk delivery
9. `PlayStatus(PlayerSpawn)`
10. Player initialization confirmation

The order matters. Sending `PlayerSpawn` before chunks, omitting the item registry, or opening the same container twice can result in anything from an empty world to a client crash.

This was one of the most interesting parts of the project. Many times, the packet format was correct, but the timing was wrong.

### `Minecraft.Bedrock.Codec` and `Packet`: The Game Protocol

After RakNet, game packets are grouped into batches identified by `0xFE`. These batches may use compression and contain several packets, each prefixed by its own size.

`Minecraft.Bedrock.Codec` handles the batch. `Minecraft.Bedrock.Packet` understands the fields of each packet.

This division looks similar to the Java side, but there is one extra layer:

```text
UDP
  -> RakNet FrameSet
  -> RakNet Frame
  -> Bedrock batch
  -> Bedrock packet
  -> game action
```

Separating these layers made debugging much easier. When the client disconnects, we can determine whether the problem is in the datagram, frame, compression, packet size, or sequence semantics.

## `Minecraft.World`: One Shared Source of Truth

Java and Bedrock arrive through different paths, but both end up in the same `Minecraft.World`.

This module is a `GenServer` responsible for:

- initializing the seed
- keeping loaded chunks in memory
- generating a chunk when requested for the first time
- serializing block mutations
- loading persisted mutations
- running autosave

Its public API is small:

```elixir
Minecraft.World.get_chunk(chunk_x, chunk_z)
Minecraft.World.set_block(x, y, z, type)
Minecraft.World.save()
```

A small API is an important quality here. The rest of the server does not need to know the internal shape of the cache or the NIF resource.

### Global Coordinates and Local Coordinates

A chunk is 16 blocks wide on the X axis and 16 blocks wide on the Z axis. To change one block, we need to find the owning chunk and its local position.

```elixir
chunk_x = Integer.floor_div(x, 16)
chunk_z = Integer.floor_div(z, 16)
local_x = Integer.mod(x, 16)
local_z = Integer.mod(z, 16)
```

Using `floor_div` and `mod` matters here. Truncated division usually works on the positive side and fails as soon as the player crosses coordinate zero. In chunk `-1`, for example, the global block `x = -1` must become `local_x = 15`, not `-1`.

This kind of bug only appears when you walk toward the “wrong” side of the map. One test with negative coordinates is worth more than ten happy tests around the origin.

### Why Do All Writes Pass Through One Process?

The chunk is a resource allocated in C. Mutating it directly from several sessions would create concurrent writes and state that is difficult to reproduce.

Because of that, every mutation passes through `Minecraft.World.set_block/4`. The `GenServer` mailbox serializes these operations.

```text
Session A breaks a block ----+
                             +-> Minecraft.World -> NIF.set_block/5
Session B places a block ----+
```

The model is simple: many readers, one write path.

At the current stage, sessions may read block types to encode chunks while the world process writes an aligned `uint16_t`. They may observe the previous value or the new value, but not a partially written value on the target architectures. For a more robust version, immutable snapshots or per-chunk versioning would be natural improvements.

## Persistence: Save the Difference, Not the Entire World

The chunk held by Elixir is not a regular map. It contains a reference to an opaque NIF resource, managed by the BEAM runtime and allocated in C.

Trying to write this resource directly with `term_to_binary/1` does not represent the real chunk contents. Even if we could store that term, its pointer would have no meaning after the process restarted.

The solution was to use one useful property of the world: the base terrain is deterministic.

With the same seed and coordinates, the generator creates the same chunk. So we do not need to persist millions of blocks that never changed. We only need to store player mutations.

```text
final chunk = terrain(seed, x, z) + persisted mutations
```

For each chunk, storage keeps a map similar to this:

```elixir
%{
  {1, 72, 3} => 16,
  {15, 80, 0} => 0
}
```

The key is `{local_x, y, local_z}`. The value is the internal block type. Placing air is also a mutation because it represents a block removed from the original terrain.

When a chunk loads:

1. The NIF regenerates the base terrain
2. Storage looks for that chunk file
3. Valid mutations are applied again
4. The chunk enters the cache

When a player changes a block, the world marks that chunk as dirty. Every 30 seconds, only dirty chunks are written.

### Atomic Writes

Writing directly to the final file creates a risk. If the process dies in the middle of the write, the file may be left incomplete.

Storage uses a different flow:

```text
serialize a versioned term
  -> write a temporary file with :sync
  -> rename it to the final path
```

The rename on the same filesystem becomes the atomic swap point. A reader sees the previous version or the new one, never a partially written intermediate file.

The format also contains a version:

```elixir
%{version: 1, blocks: mutations}
```

This leaves room for future migrations. It can feel like an early concern until the first incompatible save appears after a deployment.

In Docker, `/data/world` is a volume. Without it, recreating the container would erase changes even if persistence worked perfectly inside that container.

## The C Layer: Where the World Is Born

Elixir is great at coordinating processes, connections, and state. Generating and serializing thousands of blocks is a different kind of work.

The project uses C NIFs for the heavy part:

```text
src/perlin.c   -> noise and octaves
src/biome.c    -> biome distribution
src/chunk.c    -> blocks, lighting, and Java serialization
src/nifs.c     -> bridge between the BEAM and C
```

### NIF Resources and Their Lifecycle

A chunk is allocated with `enif_alloc_resource`. Elixir receives a term referencing that resource, but it never manipulates the pointer directly.

When the term is no longer reachable, the BEAM garbage collector calls the destructor registered by the NIF. That destructor frees the heightmap, biomes, and every allocated section.

This creates a safe bridge between two memory models:

```text
%Minecraft.Chunk{resource: nif_resource}
                         |
                         v
                   C struct Chunk
```

The most expensive functions, such as `generate_chunk/2` and `serialize_chunk/1`, are registered with `ERL_NIF_DIRTY_JOB_CPU_BOUND`. This prevents terrain generation from occupying a normal BEAM scheduler for too long.

That detail is essential. A fast NIF can run on a normal scheduler. A heavy NIF that never yields can freeze latency across the entire system.

### Heightmaps with Perlin Noise

For every X/Z column in a chunk, the generator calculates a height using six octaves of Perlin noise.

Each octave increases frequency and reduces amplitude. The first octaves define the larger terrain shapes. Later octaves add smaller details.

```text
height = octave_perlin(x, y, z, 6, 0.4) * 125
```

Then `generate_chunk_section` decides which block belongs in each position:

- bedrock in the lower layers
- stone below the surface
- dirt close to the surface
- grass on top
- sand in low regions
- water up to level 64
- air above the terrain
- tall grass in selected positions

The PRNG used to initialize the tables is `splitmix64`. This avoids depending on libc `rand()`, which may produce different sequences across platforms. The same seed needs to generate the same world on a laptop, on the server, and inside Docker, especially because persistence depends on this property.

### Biomes with Voronoi

The heightmap defines the shape of the terrain. The biome map defines the type of region represented by each column.

The generator divides the world into zones, creates deterministic points in nearby zones, and chooses the closest point for each coordinate. In practice, it is a Voronoi-based distribution.

The current biomes include ocean, plains, desert, forest, taiga, swamp, ice plains, jungle, and birch forest.

Even though vegetation does not use all this information yet, sending real biomes changes water, grass, and foliage colors, which changes how the client perceives the world.

## One Chunk, Two Network Formats

This is one of my favorite parts of the architecture.

The in-memory chunk is shared. Its serialization is not.

Java 1.12 expects sections with global IDs, 13-bit packing, block light, sky light, heightmap data, and biomes in that version's format.

Bedrock 1.26 expects v9 subchunks, paletted storages, network block ID hashes, biome storage, and other metadata.

So the flow looks like this:

```text
                        C struct Chunk
                              |
             +----------------+----------------+
             |                                 |
       Java serializer                Minecraft.Bedrock.Chunk
       protocol 340                   protocol 1001
             |                                 |
       ChunkData TCP                    LevelChunk UDP
```

`Minecraft.Bedrock.Chunk` reads sections as a binary containing 4096 `uint16_t` values, converts every Java type into the canonical Bedrock block name, and calculates its network hash.

The server enables `UseBlockNetworkIDHashes`. This means it does not need to keep a massive runtime ID table for every game build. It calculates FNV-1a hashes from normalized block states.

There is also a reverse path. When the client reports the hash of the held block, the adapter finds the corresponding internal type. This allows selecting a block in creative inventory to influence what is actually placed in the world.

That is what a good boundary should do: the domain does not learn protocol details, and the adapter does not create a second source of truth.

## From Movement to an Effectively Infinite World

On Bedrock, the client sends `PlayerAuthInput` several times per second. The session updates position and rotation, handles block actions, and checks whether the player crossed a chunk boundary.

```elixir
center = {floor(px / 16), floor(pz / 16)}
```

If the center changes, the session first sends a `NetworkChunkPublisherUpdate`. Then it calculates which chunks are inside the radius and have not been sent to that client yet.

Every session keeps a `MapSet` called `sent_chunks`. This prevents the same chunk from being sent again after every movement packet.

For each new chunk:

1. `Minecraft.World.get_chunk/2` finds or generates it
2. `Minecraft.Bedrock.Chunk.encode/1` converts it to Bedrock
3. `Packet.encode_level_chunk/4` builds the packet
4. The codec compresses the batch
5. RakNet fragments it if it crosses the MTU
6. The listener sends it over UDP

It is a long chain, but every step can be tested separately.

## Breaking One Block Crosses the Entire System

A simple action shows how all these modules work together.

When a Bedrock player breaks a block:

```text
PlayerAuthInput
  -> Bedrock.Packet.decode
  -> Bedrock.Session.handle_break_block
  -> World.set_block(x, y, z, air)
  -> NIF.set_block on the C resource
  -> record mutation and mark chunk dirty
  -> UpdateBlock back to the client
  -> autosave into an atomic file
```

Every layer answers a different question:

- Is the packet well formed?
- Is the action supported?
- Is the coordinate valid?
- Which chunk owns this block?
- How should the C state change?
- How do we confirm the change through the client protocol?
- How do we recover the change after a restart?

If all of this lived inside `handle_info({:udp, ...})`, adding multiplayer would be a nightmare.

## Testing: Bytes Before the Interface

Testing a game server only by opening the client is slow and not very deterministic.

The project uses three levels of testing.

### 1. Pure Codec Tests

VarInts, frames, frame sets, ACKs, NAKs, and packets have encode/decode tests. These tests find endianness mistakes and incorrect lengths without starting sockets.

### 2. Elixir Integration Tests

A TCP test client goes through the Java handshake, status, ping, encrypted login, and initial game packets.

World storage also has a restart test. It changes blocks, saves them, stops the process, starts another world, and verifies the values inside the NIF resource. The case uses negative coordinates to protect exactly the conversion between global and local positions.

### 3. A Headless Bedrock Client

Scripts based on `bedrock-protocol` connect as a real Bedrock client. One validates the complete spawn sequence. Another breaks and places blocks, then waits for server confirmations.

A phone is still useful for validating visual behavior and client-specific crashes. But it has become the final stage, not the first one.

## What This Foundation Already Supports

Today, the architecture supports:

- Java Edition 1.12.2 over TCP
- Bedrock Edition 1.26.x over UDP and RakNet
- one world shared between both editions
- deterministic terrain using Perlin noise
- biome distribution based on Voronoi
- chunk streaming as the player moves
- block breaking and placement on Bedrock
- creative inventory and item registry
- mutation persistence with autosave
- Docker release builds

There are still important limitations:

- block changes still need to be broadcast to every session
- Bedrock players cannot see other players yet
- NAK does not trigger retransmission yet
- ordered channels need full enforcement
- Bedrock sessions need their own timeout
- the chunk cache has no eviction policy
- survival gameplay is still very basic
- inventory needs authoritative server-side state

A good foundation does not remove the work ahead. It gives that work a clear place to live.

## The Next Modules That Make Sense

The natural next step is real multiplayer.

Instead of each session confirming a change only to the client that created it, `Minecraft.World` can publish events such as:

```elixir
{:block_changed, %{x: x, y: y, z: z, type: type, source: player_id}}
```

Java and Bedrock adapters can subscribe to these events and translate the same change into their own packet formats.

The same pattern can later support:

- players joining and leaving
- movement
- chat
- entity spawning
- world time
- health and damage

I also want to separate RakNet reliability into a process or module with a send window, a buffer of unacknowledged frames, and retransmission timers. Today, the session mixes transport state and gameplay state because that helped reach the first working client faster. The architecture already shows where the next separation should happen.

That is a practical lesson that applies to other projects too: first find the real boundaries. Then refine what lives inside them.

## What I Learned While Building This

A few things became very clear during development.

### Protocols Are More About Sequence Than Structs

Having every field correct does not guarantee that the client will accept a packet. On Bedrock, order, active compression, current state, and previous packets are all part of the contract.

### OTP Works Really Well When State Is Concurrent

Listeners, sessions, the world, and registries all have different lifecycles. Processes make these boundaries visible, and supervisors turn failures into local decisions.

### One Internal Representation Prevents Domain Duplication

Java and Bedrock disagree about IDs, framing, and transport. They do not need to disagree about which block exists at coordinate `{10, 70, -4}`.

### A NIF Should Be a Surgical Tool

Writing the entire network layer in C would not make sense. Turning millions of block operations into individual Elixir messages would not make sense either. The NIF lives exactly where compact memory and numerical loops matter.

### Persistence Can Take Advantage of Determinism

Saving only mutations reduced the problem because the base terrain can be reconstructed. Sometimes the best persistence format is not a complete snapshot. It is the smallest amount of information required to rebuild the state.

## Running the Project

To run it natively, you need Elixir, Erlang/OTP, and a C compiler:

```bash
mix deps.get
mix run --no-halt
```

With Docker:

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

Then, on Bedrock, add the machine IP using port `19132`.

## The Main Point

Building a Minecraft server from scratch is not only about implementing packets until the client stops disconnecting.

The real challenge is creating an architecture where transport, protocol, session, domain, generation, and persistence can evolve without becoming the same thing.

Elixir and OTP handle coordination really well. C handles the heavy loops and compact chunk representation. The Java and Bedrock adapters translate two protocol worlds into one source of truth.

There is still plenty to build, but every next feature now has a natural place to exist. For me, that is the sign of a good technical foundation.

Have questions, want to contribute, or have you tried implementing a game protocol before? Find me on [Twitter](https://x.com/iagoangelimc) or [LinkedIn](https://linkedin.com/in/iago-a-cavalcante).

That is it, everyone! Want to test it?
