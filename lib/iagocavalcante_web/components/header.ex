defmodule IagocavalcanteWeb.Header do
  use Phoenix.Component

  slot :nav_items, required: true
  slot :toggle_items, required: true

  def header(assigns) do
    ~H"""
    <header
      class="pointer-events-none relative z-50 flex flex-col"
      style="height:var(--header-height);margin-bottom:var(--header-mb)"
    >
      <div class="top-0 z-10 h-16 pt-6" style="position:var(--header-position)">
        <div
          class="sm:px-8 top-[var(--header-top,theme(spacing.6))] w-full"
          style="position:var(--header-inner-position)"
        >
          <div class="mx-auto max-w-7xl lg:px-8">
            <div class="relative px-4 sm:px-8 lg:px-12">
              <div class="mx-auto max-w-2xl lg:max-w-5xl">
                <div class="relative flex gap-4">
                  <div class="flex flex-1">
                    <div class="h-10 w-10 rounded-full bg-white/90 p-0.5 shadow-lg shadow-zinc-800/5 ring-1 ring-zinc-900/5 backdrop-blur dark:bg-zinc-800/90 dark:ring-white/10">
                      <a aria-label="Home" class="pointer-events-auto" href="/">
                        <img
                          alt=""
                          sizes="2.25rem"
                          srcset="/images/myself-1.png"
                          src="/images/myself-1.png"
                          decoding="async"
                          data-nimg="1"
                          class="rounded-full bg-zinc-100 object-cover dark:bg-zinc-800 h-9 w-9"
                          style="color: transparent;"
                          width="512"
                          height="512"
                        />
                      </a>
                    </div>
                  </div>
                  <div class="flex flex-1 justify-end md:justify-center">
                    <div class="pointer-events-auto md:hidden" data-headlessui-state="">
                      <button
                        class="group flex items-center rounded-full bg-white/90 px-4 py-2 text-sm font-medium text-zinc-800 shadow-lg shadow-zinc-800/5 ring-1 ring-zinc-900/5 backdrop-blur dark:bg-zinc-800/90 dark:text-zinc-200 dark:ring-white/10 dark:hover:ring-white/20"
                        type="button"
                        aria-expanded="false"
                        data-headlessui-state=""
                        id="headlessui-popover-button-:Rb9cm:"
                      >
                        Menu<svg
                          viewBox="0 0 8 6"
                          aria-hidden="true"
                          class="ml-3 h-auto w-2 stroke-zinc-500 group-hover:stroke-zinc-700 dark:group-hover:stroke-zinc-400"
                        ><path
                            d="M1.75 1.75 4 4.25l2.25-2.5"
                            fill="none"
                            stroke-width="1.5"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                          ></path></svg>
                      </button>
                    </div>
                    <nav class="pointer-events-auto hidden md:block">
                      <ul class="flex rounded-full bg-white/90 px-3 text-sm font-medium text-zinc-800 shadow-lg shadow-zinc-800/5 ring-1 ring-zinc-900/5 backdrop-blur dark:bg-zinc-800/90 dark:text-zinc-200 dark:ring-white/10">
                        <%= render_slot(@nav_items) %>
                      </ul>
                    </nav>
                  </div>
                  <div class="flex justify-end md:flex-1">
                    <div class="pointer-events-auto">
                      <%= render_slot(@toggle_items) %>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>
    """
  end
end
