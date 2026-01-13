defmodule Iagocavalcante.Blog.MDExConverter do
  @moduledoc """
  Custom HTML converter for NimblePublisher using MDEx.

  Provides syntax highlighting with CSS classes and
  GitHub Flavored Markdown extensions.
  """

  @doc """
  Converts markdown content to HTML using MDEx.

  Supports:
  - GitHub Flavored Markdown (tables, strikethrough, task lists, autolinks)
  - Syntax highlighting with CSS classes (html_linked formatter)
  - Emoji shortcodes
  """
  def convert(filepath, body, _attrs, _opts) do
    if Path.extname(filepath) in [".md", ".markdown"] do
      MDEx.to_html!(body,
        extension: [
          strikethrough: true,
          table: true,
          autolink: true,
          tasklist: true,
          shortcodes: true,
          header_ids: ""
        ],
        parse: [
          smart: true,
          relaxed_autolinks: true
        ],
        render: [
          unsafe_: true
        ],
        syntax_highlight: [
          formatter: {:html_linked, pre_class: "highlight"}
        ]
      )
    else
      body
    end
  end
end
