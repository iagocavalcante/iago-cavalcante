%{
  title: "Construindo um frontend maneiro com liveview",
  author: "Iago Cavalcante",
  tags: ~w(liveview),
  description: "Neste artigo, eu irei compartilhar como eu construi esse site e como componentizar com o novo liveview.",
  locale: "pt_BR",
  published: true
}
---

Neste artigo quero trazer uma ideia interessante, como o liveview nos dias de hoje, nos traz o poder que teríamos com qualquer framework javascript no mercado, possibilitando assim ter códigos com zero ou quase zero javascript dentro da sua aplicação `Phoenix`.

O exemplo disso (ainda que incompleto) é este [site](https://github.com/iagocavalcante/iago-cavalcante), ele é baseado em um template `Tailwind` que é construído em cima do `NextJs`.

Ao começar esse projeto com a ideia de explorar o poder da componentização da versão mais recente do liveview, mantive a estrutura de componentes similiar ao que era encontrada no projeto `NextJS/React`, mas mantendo as recomendações do criador do `Phoenix`. Então na pasta `lib/iagocavalcante_web/components` estão todos os componentes globais do site. Mas ao contrário da recomendação, a primeira alteração que considero importante é dentro do módulo `core_components.ex`.

Lá estão os componentes padrões do `Phoenix` que já vem com `Tailwind` nas versões mais recentes. Quando digo os componentes, é que literalmente toda a estrutura dos componentes se encontram nesse arquivo. Mas de forma a buscar uma melhor organização, decidi criar componentes separadas, facilitando assim a manutenção e fácil localização dos mesmos.

Aqui vocês podem ver um exemplo do meu componente de mudar o Idioma do site:

```elixir
defmodule IagocavalcanteWeb.ToggleLocale do
  use Phoenix.Component

  import IagocavalcanteWeb.Gettext

  def toggle_locale(assigns) do
    ~H"""
    <button
      phx-click="toggle_locale"
      phx-value-locale={@locale}
      type="button"
      aria-label="Toggle locale"
      class="group rounded-full bg-white/90 px-3 py-2 shadow-lg shadow-zinc-800/5 ring-1 ring-zinc-900/5 backdrop-blur transition dark:bg-zinc-800/90 dark:ring-white/10 dark:hover:ring-white/20"
    >
      <img
        src={"/images/flags/#{@locale}.png"}
        class="h-6 w-6 fill-zinc-700 stroke-zinc-500 transition dark:fill-teal-400/10 dark:stroke-teal-500"
      />
    </button>
    """
  end
end
```

E para tornar ele disponível para todos as nossas `liveview's`, basta adicionar o seguinte dentro do `core_components`:

```elixir
defmodule IagocavalcanteWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  The components in this module use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn how to
  customize the generated components in this module.

  Icons are provided by [heroicons](https://heroicons.com), using the
  [heroicons_elixir](https://github.com/mveytsman/heroicons_elixir) project.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import IagocavalcanteWeb.Gettext

  #...
  #...

  defdelegate toggle_locale(assigns), to: IagocavalcanteWeb.ToggleLocale, as: :toggle_locale
end
```

Feito isso, dentro do nosso `lib/iagocavalcante_web/components/layouts/app.html.heex`, podemos chamar o componente que criamos e passar as propriedades que ele espera, tal qual as `props` do `React`, `Vue` e similares.

```heex
<div class="fixed inset-0 flex justify-center sm:px-8">
  <div class="flex w-full max-w-7xl lg:px-8">
    <div class="w-full bg-white ring-1 ring-zinc-100 dark:bg-zinc-900 dark:ring-zinc-300/20">
    </div>
  </div>
</div>
<div class="relative">
  <.header>
    <:nav_items>
      <.nav_item link={gettext("/about")} text={"#{gettext("About", lang: @locale)}"} active_item={@active_tab} />
      <.nav_item
        link={gettext("/articles")}
        text={"#{gettext("Articles", lang: @locale)}"}
        active_item={@active_tab}
      />
      <.nav_item
        link={gettext("/projects")}
        text={"#{gettext("Projects", lang: @locale)}"}
        active_item={@active_tab}
      />
      <.nav_item
        link={gettext("/speaking")}
        text={"#{gettext("Speaking", lang: @locale)}"}
        active_item={@active_tab}
      />
      <.nav_item link={gettext("/uses")} text={"#{gettext("Uses", lang: @locale)}"} active_item={@active_tab} />
    </:nav_items>
    <:toggle_items>
      <.toggle_locale locale={@locale} />
      <.live_component module={IagocavalcanteWeb.ToggleTheme} theme={@theme} id="theme" />
    </:toggle_items>
  </.header>
  <main>
    <%= @inner_content %>
  </main>
  <.footer />
</div>
```

No exemplo acima, o nosso `lib/iagocavalcante_web/components/layouts/app.html.heex` conta até mesmo com a ajuda de slot, para facilitar a composição da interface gráfica.

Era isso pessoal, espero que tenham gostado das postagem, feedbacks e comentários são sempre bem-vindos. Vocês podem estar enviando emails para `iagocavalcante@hey.com`.

Até a próxima.
