defmodule IagocavalcanteWeb.Footer do
  use Phoenix.Component
  use Gettext, backend: IagocavalcanteWeb.Gettext

  def footer(assigns) do
    ~H"""
    <footer class="mt-32 relative">
      <!-- Simple top border -->
      <div class="absolute top-0 left-0 right-0 h-px" style="background-color: var(--border);"></div>

      <div class="sm:px-8">
        <div class="mx-auto max-w-7xl lg:px-8">
          <div class="pt-10 pb-16">
            <div class="relative px-4 sm:px-8 lg:px-12">
              <div class="mx-auto max-w-2xl lg:max-w-5xl">
                <div class="flex flex-col items-center justify-between gap-6 sm:flex-row">
                  <!-- Navigation Links -->
                  <div class="flex flex-wrap justify-center gap-x-6 gap-y-2 text-sm font-medium text-ink-light">
                    <a
                      class="editorial-link py-1"
                      href="/about"
                    >
                      About
                    </a>
                    <a
                      class="editorial-link py-1"
                      href="/projects"
                    >
                      Projects
                    </a>
                    <a
                      class="editorial-link py-1"
                      href="/speaking"
                    >
                      Speaking
                    </a>
                    <a
                      class="editorial-link py-1"
                      href="/uses"
                    >
                      Uses
                    </a>
                  </div>
                  
    <!-- Copyright -->
                  <p class="text-sm text-muted">
                    <span>&copy;</span>
                    <span class="mx-1">{DateTime.utc_now().year}</span>
                    <span class="font-medium text-ink">Iago Cavalcante</span>
                    <span>. {gettext("All rights reserved.")}</span>
                  </p>
                </div>
                
    <!-- Minimal decorative element -->
                <div class="mt-8 flex justify-center">
                  <div class="h-px w-16" style="background-color: var(--border);"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </footer>
    """
  end
end
