%{
  title: "Building a Real-time Chat Interface with Phoenix LiveView and OpenAI",
  author: "Iago Cavalcante",
  tags: ~w(elixir phoenix liveview openai chat realtime streaming async),
  description: "Learn how to create a robust, real-time chat interface using Phoenix LiveView integrated with OpenAI's streaming API, featuring comprehensive error handling and a polished user experience.",
  locale: "en",
  published: true
}
---

# Building a Real-time Chat Interface with Phoenix LiveView and OpenAI

In this comprehensive guide, I'll walk you through building a real-time chat application using Phoenix LiveView and OpenAI's API. We'll focus on implementing streaming responses, async processing, and error handling to create a smooth user experience.

## Why Phoenix LiveView for Chat?

Phoenix LiveView is an excellent choice for building real-time chat applications because it provides:

1. Real-time updates without complex WebSocket management
2. Efficient server-side rendering
3. Minimal JavaScript footprint
4. Built-in streaming support
5. Robust error handling and state management

## Core Implementation

Let's break down the implementation into key components:

### 1. LiveView Setup

First, we set up our LiveView module with necessary assigns:

```elixir
defmodule ChatLive do
  use Phoenix.LiveView

  @timeout 30_000  # 30 second timeout for responses
  @retry_attempts 3

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:message, "")
      |> assign(:loading, false)
      |> assign(:error, nil)
      |> assign(:streaming_message, nil)
      |> assign(:messages, [])
      |> assign(:message_queue, :queue.new())
      |> assign(:processing, false)
      |> stream(:messages, [])

    {:ok, socket}
  end
end
```

### 2. Message Processing with Async Tasks

Following the pattern described in [LiveView Async Task](https://fly.io/phoenix-files/liveview-async-task/), we implement async processing using LiveView's `start_async`:

```elixir
def handle_event("submit", %{"message" => message}, socket) when message != "" do
  if can_submit?(socket) do
    user_message = Chat.create_message("user", message)
    assistant_message = Chat.create_message("assistant", "")
    previous_messages = socket.assigns.messages ++ [user_message]

    socket =
      socket
      |> stream_insert(:messages, user_message)
      |> stream_insert(:messages, assistant_message)
      |> assign(:loading, true)
      |> assign(:messages, previous_messages)
      |> assign(:message, "")
      |> assign(:streaming_message, assistant_message)
      |> assign(:processing, true)
      |> start_async(:process_message, fn ->
        Chat.process_message(message, previous_messages)
      end)

    Process.send_after(self(), {:timeout, message}, @timeout)

    {:noreply, socket}
  else
    {:noreply, socket}
  end
end
```

### 3. Handling Async Results

We handle the async results using `handle_async` callbacks:

```elixir
def handle_async(:process_message, {:ok, {:ok, _user_msg, response}}, socket) do
  ChatAPI.stream_message(response, fn
    {:chunk, content} -> send(self(), {:stream_chunk, content})
    {:done} -> send(self(), :stream_complete)
    {:error, error} -> send(self(), {:stream_error, error, @retry_attempts - 1, socket.assigns.message})
  end)

  {:noreply, socket}
end

def handle_async(:process_message, {:ok, {:error, error}}, socket) do
  {:noreply,
   socket
   |> assign(:loading, false)
   |> assign(:processing, false)
   |> assign(:streaming_message, nil)
   |> assign(:error, error)
   |> maybe_process_next_message()}
end
```

### 4. Streaming Response Handling

The streaming implementation follows a pattern where we:
1. Start streaming in the async handler
2. Process chunks as they arrive
3. Update the UI in real-time

```elixir
def handle_info({:stream_chunk, content}, socket) do
  if socket.assigns.streaming_message do
    updated_message = Chat.update_message(socket.assigns.streaming_message, content)

    {:noreply,
     socket
     |> stream_insert(:messages, updated_message, at: -1)
     |> assign(:streaming_message, updated_message)
     |> assign(:messages, update_messages(socket.assigns.messages, updated_message))
     |> push_event("scroll", %{to: "bottom"})}
  else
    {:noreply, socket}
  end
end

def handle_info(:stream_complete, socket) do
  {:noreply,
   socket
   |> assign(:loading, false)
   |> assign(:processing, false)
   |> assign(:streaming_message, nil)
   |> maybe_process_next_message()
   |> push_event("scroll", %{to: "bottom"})}
end
```

### 5. Error Handling and Recovery

We implement a comprehensive error handling system with retries:

```elixir
def handle_info({:stream_error, error, attempts, message}, socket) do
  if attempts > 0 do
    Process.send_after(self(), {:retry, message, attempts}, 1000)
    {:noreply, socket}
  else
    {:noreply,
     socket
     |> assign(:loading, false)
     |> assign(:processing, false)
     |> assign(:streaming_message, nil)
     |> assign(:error, error)
     |> maybe_process_next_message()}
  end
end
```

### 6. Message Queue Management

To handle multiple messages reliably:

```elixir
defp queue_message(socket, message) do
  update(socket, :message_queue, &:queue.in({message, @retry_attempts}, &1))
end

defp maybe_process_next_message(%{assigns: %{processing: true}} = socket), do: socket
defp maybe_process_next_message(%{assigns: %{message_queue: queue}} = socket) do
  case :queue.out(queue) do
    {{:value, {message, attempts}}, new_queue} ->
      process_message_with_retry(socket, message, attempts, new_queue)
    {:empty, _} ->
      socket
  end
end
```

## Key Features and Benefits

1. **Real-time Updates**: Messages appear instantly with typing indicators
2. **Streaming Responses**: OpenAI responses stream in real-time
3. **Error Resilience**: Automatic retries and graceful error handling
4. **Queue Management**: Ordered processing of multiple messages
5. **State Management**: Clean handling of loading and processing states

## Best Practices

1. **Extract Messages Before Async**
   ```elixir
   # Before async operation
   previous_messages = socket.assigns.messages ++ [user_message]

   # Use in async function
   start_async(:process_message, fn ->
     Chat.process_message(message, previous_messages)
   end)
   ```

2. **Clear States at Right Time**
   ```elixir
   # Only clear states after streaming is complete
   def handle_info(:stream_complete, socket) do
     {:noreply,
      socket
      |> assign(:loading, false)
      |> assign(:processing, false)
      |> assign(:streaming_message, nil)}
   end
   ```

3. **Handle Timeouts**
   ```elixir
   # Set timeout when starting async operation
   Process.send_after(self(), {:timeout, message}, @timeout)
   ```

## References

1. [LiveView Async Task](https://fly.io/phoenix-files/liveview-async-task/) - Great overview of async processing in LiveView
2. [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)
3. [OpenAI Streaming Best Practices](https://platform.openai.com/docs/api-reference/streaming)

## What's Next?

Consider these enhancements for your chat application:

- [ ] Implement rate limiting for API calls
- [ ] Add conversation persistence with Ecto
- [ ] Include user authentication
- [ ] Add typing indicators between messages
- [ ] Implement message reactions

The complete code for this implementation is available in my [GitHub repository](https://github.com/IagoCavalcante/elixir-open-ai).

For more Elixir deployment tips, check out my guide on [deploying Phoenix apps to Fly.io](https://fly.io/docs/elixir/getting-started/).

Happy coding! 🚀
