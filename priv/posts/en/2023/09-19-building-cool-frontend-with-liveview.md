%{
  title: "Building a cool frontend with liveview",
  author: "Iago Cavalcante",
  tags: ~w(liveview),
  description: "In this article, I share how I built this site and how to componize with new liveview stuffs.",
  locale: "en",
  published: true
}
---

In this article, I want to introduce an interesting concept: how LiveView, in today's landscape, provides us with the power we'd typically associate with any JavaScript framework in the market. This allows us to create applications in Phoenix with minimal or almost no JavaScript.

An example of this (albeit incomplete) can be seen in this [site](https://github.com/iagocavalcante/iago-cavalcante). It's based on a `Tailwind` template and built on top of `NextJs`.

When I started this project with the idea of exploring the componentization power of the latest LiveView version, I kept the component structure similar to what you would find in a `NextJS/React` project. However, I followed the recommendations of the creator of `Phoenix`. So, all the global site components can be found in the `lib/iagocavalcante_web/components` folder. But contrary to the recommendation, the first important change I made was within the `core_components.ex` module.

In that file, you'll find the default components that come with `Phoenix`, already integrated with `Tailwind` in the latest versions. When I say "components," I mean that literally all the component structures are in this file. However, in order to achieve better organization, I decided to create separate components, making maintenance and easy access much simpler.

Here's an example of one of my site's language-switching components:

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

To make it available to all our LiveViews, you only need to add the following code within `core_components`:

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

With that in place, within our `lib/iagocavalcante_web/components/layouts/app.html.heex`, we can call the component we created and pass the properties it expects, much like `props` in `React`, `Vue`, and similar frameworks.

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

In the example above, our `lib/iagocavalcante_web/components/layouts/app.html.heex` even uses slots to simplify the graphical interface composition.

That's it, folks! I hope you enjoyed the post. Feedback and comments are always welcome. You can send emails to `iagocavalcante@hey.com`.

Until next time.
