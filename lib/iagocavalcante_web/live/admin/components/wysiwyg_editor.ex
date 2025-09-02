defmodule IagocavalcanteWeb.Admin.Components.WysiwygEditor do
  use IagocavalcanteWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, 
     socket
     |> assign(:editor_mode, :visual)
     |> assign(:toolbar_visible, false)
     |> assign(:focus_mode, false)
     |> assign(:word_count, 0)
     |> assign(:read_time, 0)}
  end

  @impl true
  def update(assigns, socket) do
    content = assigns[:content] || ""
    word_count = count_words(content)
    read_time = calculate_read_time(word_count)
    
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:word_count, word_count)
     |> assign(:read_time, read_time)
     |> assign(:parent_id, assigns[:parent_id] || "new_post")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="wysiwyg-editor" id={"editor-#{@id}"}>
      <!-- Editor Header -->
      <div class="editor-header flex items-center justify-between mb-6 pb-4 border-b border-gray-200 dark:border-gray-700">
        <div class="flex items-center space-x-4">
          <button 
            type="button" 
            phx-click="toggle_mode" 
            phx-target={@myself}
            class={["px-3 py-1.5 text-sm rounded-md transition-colors", if(@editor_mode == :visual, do: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200", else: "bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-gray-800 dark:text-gray-300")]}
          >
            <%= if @editor_mode == :visual, do: "Visual", else: "Markdown" %>
          </button>
          <button 
            type="button" 
            phx-click="toggle_focus" 
            phx-target={@myself}
            class={["px-3 py-1.5 text-sm rounded-md transition-colors", if(@focus_mode, do: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200", else: "bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-gray-800 dark:text-gray-300")]}
          >
            Focus Mode
          </button>
        </div>
        <div class="flex items-center space-x-4 text-sm text-gray-500 dark:text-gray-400">
          <span><%= @word_count %> words</span>
          <span><%= @read_time %> min read</span>
        </div>
      </div>

      <!-- Formatting Toolbar (Visual Mode Only) -->
      <div :if={@editor_mode == :visual and @toolbar_visible} 
           class="formatting-toolbar flex items-center space-x-2 mb-4 p-3 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-600 rounded-lg shadow-sm">
        
        <!-- Text Formatting -->
        <div class="flex items-center space-x-1 border-r border-gray-200 dark:border-gray-600 pr-3">
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="bold" phx-target={@myself} title="Bold">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path d="M3 5a2 2 0 012-2h5.5a3.5 3.5 0 110 7H5v4a2 2 0 01-2-2V5zM5 5v4h5.5a1.5 1.5 0 000-3H5z"/>
            </svg>
          </button>
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="italic" phx-target={@myself} title="Italic">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path d="M8.5 3.5A.5.5 0 019 3h3a.5.5 0 010 1h-1.25l-1 8H11a.5.5 0 010 1H8a.5.5 0 010-1h1.25l1-8H9a.5.5 0 01-.5-.5z"/>
            </svg>
          </button>
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="code" phx-target={@myself} title="Inline Code">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M12.316 3.051a1 1 0 01.633 1.265l-4 12a1 1 0 11-1.898-.632l4-12a1 1 0 011.265-.633zM5.707 6.293a1 1 0 010 1.414L3.414 10l2.293 2.293a1 1 0 11-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0zm8.586 0a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 11-1.414-1.414L16.586 10l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd"/>
            </svg>
          </button>
        </div>

        <!-- Headings -->
        <div class="flex items-center space-x-1 border-r border-gray-200 dark:border-gray-600 pr-3">
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="h1" phx-target={@myself} title="Heading 1">H1</button>
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="h2" phx-target={@myself} title="Heading 2">H2</button>
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="h3" phx-target={@myself} title="Heading 3">H3</button>
        </div>

        <!-- Lists & Links -->
        <div class="flex items-center space-x-1 border-r border-gray-200 dark:border-gray-600 pr-3">
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="ul" phx-target={@myself} title="Bullet List">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"/>
            </svg>
          </button>
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="ol" phx-target={@myself} title="Numbered List">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"/>
            </svg>
          </button>
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="link" phx-target={@myself} title="Link">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M12.586 4.586a2 2 0 112.828 2.828l-3 3a2 2 0 01-2.828 0 1 1 0 00-1.414 1.414 4 4 0 005.656 0l3-3a4 4 0 00-5.656-5.656l-1.5 1.5a1 1 0 101.414 1.414l1.5-1.5zm-5 5a2 2 0 012.828 0 1 1 0 101.414-1.414 4 4 0 00-5.656 0l-3 3a4 4 0 105.656 5.656l1.5-1.5a1 1 0 10-1.414-1.414l-1.5 1.5a2 2 0 11-2.828-2.828l3-3z" clip-rule="evenodd"/>
            </svg>
          </button>
        </div>

        <!-- Block Elements -->
        <div class="flex items-center space-x-1">
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="quote" phx-target={@myself} title="Quote">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"/>
            </svg>
          </button>
          <button type="button" class="toolbar-btn" phx-click="format" phx-value-type="codeblock" phx-target={@myself} title="Code Block">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clip-rule="evenodd"/>
            </svg>
          </button>
        </div>
      </div>

      <!-- Editor Container -->
      <div class={["editor-container transition-all duration-300", if(@focus_mode, do: "focus-mode", else: "")]}>
        
        <!-- Visual Editor -->
        <div :if={@editor_mode == :visual} class="visual-editor">
          <div 
            id={"visual-editor-#{@id}"}
            class="visual-content"
            contenteditable="true"
            phx-hook="VisualEditor"
            phx-update="ignore"
            phx-click="show_toolbar"
            phx-target={@myself}
            data-content={@content}
            data-target={@myself}
            style="min-height: 500px; outline: none; padding: 2rem 0;"
            spellcheck="true"
          >
            <%= raw(markdown_to_html(@content || "")) %>
          </div>
          
          <!-- Hidden textarea to capture content changes -->
          <textarea
            id={"visual-content-#{@id}"}
            name={@name}
            phx-change="content_changed"
            phx-target={@myself}
            style="display: none;"
          ><%= @content %></textarea>
        </div>

        <!-- Markdown Editor -->
        <div :if={@editor_mode == :markdown} class="markdown-editor">
          <textarea
            id={"markdown-editor-#{@id}"}
            name={@name}
            phx-change="content_changed"
            phx-target={@myself}
            class="markdown-content w-full border-none outline-none resize-none font-mono text-base leading-relaxed"
            style="min-height: 500px; padding: 2rem 0;"
            placeholder="Start writing your story..."
          ><%= @content %></textarea>
        </div>
      </div>

      <!-- Hidden input for form submission -->
      <input type="hidden" name={@name} value={@content} id={"hidden-#{@id}"} />
      
      <!-- Component Styles -->
      <style>
      .wysiwyg-editor {
        max-width: 740px;
        margin: 0 auto;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      }

      .toolbar-btn {
        @apply p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded transition-colors;
      }

      .visual-content {
        line-height: 1.8;
        color: #333;
        font-size: 18px;
      }

      .visual-content:focus {
        outline: none;
      }

      .visual-content h1 {
        font-size: 2.5rem;
        font-weight: 700;
        line-height: 1.2;
        margin: 2rem 0 1rem 0;
        color: #1a1a1a;
      }

      .visual-content h2 {
        font-size: 2rem;
        font-weight: 600;
        line-height: 1.3;
        margin: 1.5rem 0 0.75rem 0;
        color: #1a1a1a;
      }

      .visual-content h3 {
        font-size: 1.5rem;
        font-weight: 600;
        line-height: 1.4;
        margin: 1.25rem 0 0.5rem 0;
        color: #1a1a1a;
      }

      .visual-content p {
        margin: 1rem 0;
        color: #333;
      }

      .visual-content blockquote {
        border-left: 4px solid #e5e5e5;
        padding-left: 1.5rem;
        margin: 1.5rem 0;
        font-style: italic;
        color: #666;
      }

      .visual-content code {
        background: #f5f5f5;
        padding: 0.25rem 0.5rem;
        border-radius: 4px;
        font-family: 'SF Mono', Monaco, Consolas, monospace;
        font-size: 0.9em;
      }

      .visual-content pre {
        background: #f8f8f8;
        padding: 1rem;
        border-radius: 8px;
        overflow-x: auto;
        margin: 1.5rem 0;
      }

      .visual-content ul, .visual-content ol {
        margin: 1rem 0 1rem 1.5rem;
      }

      .visual-content li {
        margin: 0.5rem 0;
      }

      .visual-content a {
        color: #1a73e8;
        text-decoration: none;
      }

      .visual-content a:hover {
        text-decoration: underline;
      }

      .markdown-content {
        background: transparent;
        line-height: 1.8;
        font-size: 16px;
      }

      .markdown-content::placeholder {
        color: #999;
        font-style: italic;
      }

      .focus-mode {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: white;
        z-index: 50;
        padding: 2rem;
        overflow-y: auto;
      }

      @media (prefers-color-scheme: dark) {
        .visual-content {
          color: #e5e5e5;
        }
        
        .visual-content h1,
        .visual-content h2,
        .visual-content h3 {
          color: #f5f5f5;
        }

        .visual-content blockquote {
          border-left-color: #444;
          color: #ccc;
        }

        .visual-content code {
          background: #2a2a2a;
          color: #e5e5e5;
        }

        .visual-content pre {
          background: #1a1a1a;
          color: #e5e5e5;
        }

        .focus-mode {
          background: #1a1a1a;
        }
      }
      </style>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_mode", _params, socket) do
    new_mode = if socket.assigns.editor_mode == :visual, do: :markdown, else: :visual
    {:noreply, assign(socket, :editor_mode, new_mode)}
  end

  @impl true
  def handle_event("toggle_focus", _params, socket) do
    {:noreply, assign(socket, :focus_mode, !socket.assigns.focus_mode)}
  end

  @impl true
  def handle_event("show_toolbar", _params, socket) do
    {:noreply, assign(socket, :toolbar_visible, true)}
  end

  @impl true
  def handle_event("format", %{"type" => type}, socket) do
    # Send formatting command to JavaScript
    {:noreply, push_event(socket, "format_text", %{type: type, editor_id: "visual-editor-#{socket.assigns.id}"})}
  end

  @impl true
  def handle_event("content_changed", params, socket) do
    # Handle both markdown editor and visual editor content changes
    content = params[socket.assigns.name] || params["content"] || ""
    word_count = count_words(content)
    read_time = calculate_read_time(word_count)
    
    # Send event to parent component (FormComponent) instead of root LiveView
    send_update(IagocavalcanteWeb.Admin.PostsLive.FormComponent, 
                id: socket.assigns.parent_id, 
                editor_content: content)
    
    {:noreply, 
     socket
     |> assign(:content, content)
     |> assign(:word_count, word_count)
     |> assign(:read_time, read_time)}
  end

  # Private helpers
  defp count_words(content) when is_binary(content) do
    content
    |> String.trim()
    |> String.split(~r/\s+/)
    |> Enum.reject(&(&1 == ""))
    |> length()
  end

  defp count_words(_), do: 0

  defp calculate_read_time(word_count) do
    max(1, div(word_count, 200))  # Average 200 words per minute
  end

  defp markdown_to_html(content) when is_binary(content) do
    content
    |> String.replace(~r/^# (.*)$/m, "<h1>\\1</h1>")
    |> String.replace(~r/^## (.*)$/m, "<h2>\\1</h2>")
    |> String.replace(~r/^### (.*)$/m, "<h3>\\1</h3>")
    |> String.replace(~r/\*\*(.*?)\*\*/m, "<strong>\\1</strong>")
    |> String.replace(~r/\*(.*?)\*/m, "<em>\\1</em>")
    |> String.replace(~r/`(.*?)`/m, "<code>\\1</code>")
    |> String.replace(~r/\[([^\]]+)\]\(([^)]+)\)/m, "<a href=\"\\2\">\\1</a>")
    |> String.replace(~r/^> (.*)$/m, "<blockquote>\\1</blockquote>")
    |> String.replace(~r/\n\n/m, "</p><p>")
    |> then(&("<p>" <> &1 <> "</p>"))
    |> String.replace("<p></p>", "")
    |> String.replace("<p><h", "<h")
    |> String.replace("</h1></p>", "</h1>")
    |> String.replace("</h2></p>", "</h2>")
    |> String.replace("</h3></p>", "</h3>")
    |> String.replace("<p><blockquote>", "<blockquote>")
    |> String.replace("</blockquote></p>", "</blockquote>")
  end

  defp markdown_to_html(_), do: "<p>Start writing your story...</p>"
end