defmodule IagocavalcanteWeb.Header do
  use Phoenix.Component

  slot :nav_items, required: true
  slot :toggle_items, required: true

  def header(assigns) do
    ~H"""
    <!-- Mobile menu backdrop with blur -->
    <div
      id="mobile-menu-backdrop"
      class="fixed inset-0 z-40 backdrop-blur-md opacity-0 transition-all duration-500 pointer-events-none hidden md:hidden"
      style="background: linear-gradient(to bottom, rgba(28, 25, 23, 0.95), rgba(28, 25, 23, 0.8));"
      onclick="closeMobileMenu()"
    >
    </div>

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
                <div class="relative flex items-center gap-4">
                  <!-- Logo/Avatar with signature animation -->
                  <div class="flex flex-1">
                    <a
                      aria-label="Home"
                      class="pointer-events-auto group relative block"
                      href="/"
                    >
                      <div class="relative">
                        <!-- Hover ring effect -->
                        <div
                          class="absolute -inset-1 rounded-full opacity-0 group-hover:opacity-100 transition-all duration-500"
                          style="background: linear-gradient(135deg, var(--accent), transparent); filter: blur(8px);"
                        >
                        </div>
                        <img
                          alt="Iago Cavalcante"
                          src="/images/myself-1.png"
                          decoding="async"
                          class="relative h-11 w-11 rounded-full object-cover border-2 transition-all duration-300 group-hover:scale-105 group-hover:border-amber-500"
                          style="border-color: var(--border);"
                          width="512"
                          height="512"
                        />
                      </div>
                    </a>
                  </div>
                  
    <!-- Navigation -->
                  <div class="flex flex-1 justify-end md:justify-center">
                    <!-- Mobile Menu Button - Hamburger style -->
                    <div class="pointer-events-auto md:hidden relative">
                      <button
                        id="mobile-menu-button"
                        class="group relative flex items-center justify-center w-11 h-11 transition-all duration-300"
                        type="button"
                        aria-expanded="false"
                        aria-label="Toggle menu"
                        onclick="toggleMobileMenu()"
                      >
                        <div class="flex flex-col items-center justify-center gap-1.5 w-6">
                          <span
                            id="hamburger-top"
                            class="block h-0.5 w-6 origin-center transition-all duration-300"
                            style="background-color: var(--ink);"
                          >
                          </span>
                          <span
                            id="hamburger-middle"
                            class="block h-0.5 w-4 transition-all duration-300 ml-auto"
                            style="background-color: var(--ink);"
                          >
                          </span>
                          <span
                            id="hamburger-bottom"
                            class="block h-0.5 w-6 origin-center transition-all duration-300"
                            style="background-color: var(--ink);"
                          >
                          </span>
                        </div>
                      </button>
                      
    <!-- Mobile Full-screen Menu -->
                      <div
                        id="mobile-menu-dropdown"
                        class="fixed inset-x-0 top-20 bottom-0 hidden z-50 overflow-hidden"
                      >
                        <nav class="flex flex-col h-full px-6 py-8">
                          <ul class="flex flex-col gap-2" id="mobile-nav-list">
                            {render_slot(@nav_items)}
                          </ul>
                          
    <!-- Mobile toggles -->
                          <div
                            class="mt-auto pt-8 border-t flex items-center justify-between"
                            style="border-color: rgba(255,255,255,0.1);"
                          >
                            <span class="text-sm font-mono text-stone-400">Settings</span>
                            <div class="flex items-center gap-3">
                              {render_slot(@toggle_items)}
                            </div>
                          </div>
                        </nav>
                      </div>
                    </div>
                    
    <!-- Desktop Navigation - Pill style -->
                    <nav class="pointer-events-auto hidden md:block">
                      <div
                        class="nav-pill relative flex items-center gap-1 px-2 py-1.5 rounded-full border"
                        style="background: var(--paper); border-color: var(--border);"
                      >
                        <!-- Active indicator (animated background) -->
                        <div
                          id="nav-indicator"
                          class="absolute h-8 rounded-full transition-all duration-300 ease-out"
                          style="background: var(--paper-dark); opacity: 0;"
                        >
                        </div>
                        <ul class="relative flex items-center gap-1 text-sm font-medium">
                          {render_slot(@nav_items)}
                        </ul>
                      </div>
                    </nav>
                  </div>
                  
    <!-- Toggle Items (Theme/Locale) - Desktop only -->
                  <div class="hidden md:flex justify-end md:flex-1">
                    <div
                      class="pointer-events-auto flex items-center gap-1 p-1 rounded-full border"
                      style="background: var(--paper); border-color: var(--border);"
                    >
                      {render_slot(@toggle_items)}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>

    <script>
      let isMenuOpen = false;

      function toggleMobileMenu() {
        isMenuOpen = !isMenuOpen;

        const dropdown = document.getElementById('mobile-menu-dropdown');
        const backdrop = document.getElementById('mobile-menu-backdrop');
        const button = document.getElementById('mobile-menu-button');
        const hamburgerTop = document.getElementById('hamburger-top');
        const hamburgerMiddle = document.getElementById('hamburger-middle');
        const hamburgerBottom = document.getElementById('hamburger-bottom');
        const navItems = document.querySelectorAll('#mobile-nav-list li');

        if (isMenuOpen) {
          // Show menu
          dropdown.classList.remove('hidden');
          backdrop.classList.remove('hidden', 'pointer-events-none');
          backdrop.classList.add('pointer-events-auto');
          button.setAttribute('aria-expanded', 'true');
          document.body.style.overflow = 'hidden';

          // Animate hamburger to X
          hamburgerTop.style.transform = 'rotate(45deg) translate(4px, 4px)';
          hamburgerTop.style.backgroundColor = '#fafaf9';
          hamburgerMiddle.style.opacity = '0';
          hamburgerMiddle.style.transform = 'translateX(10px)';
          hamburgerBottom.style.transform = 'rotate(-45deg) translate(4px, -4px)';
          hamburgerBottom.style.backgroundColor = '#fafaf9';

          // Animate backdrop
          setTimeout(() => {
            backdrop.classList.remove('opacity-0');
            backdrop.classList.add('opacity-100');
          }, 10);

          // Stagger animate nav items
          navItems.forEach((item, index) => {
            item.style.opacity = '0';
            item.style.transform = 'translateY(20px)';
            setTimeout(() => {
              item.style.transition = 'all 0.4s cubic-bezier(0.16, 1, 0.3, 1)';
              item.style.opacity = '1';
              item.style.transform = 'translateY(0)';
            }, 100 + (index * 75));
          });
        } else {
          closeMobileMenu();
        }
      }

      function closeMobileMenu() {
        isMenuOpen = false;

        const dropdown = document.getElementById('mobile-menu-dropdown');
        const backdrop = document.getElementById('mobile-menu-backdrop');
        const button = document.getElementById('mobile-menu-button');
        const hamburgerTop = document.getElementById('hamburger-top');
        const hamburgerMiddle = document.getElementById('hamburger-middle');
        const hamburgerBottom = document.getElementById('hamburger-bottom');
        const navItems = document.querySelectorAll('#mobile-nav-list li');

        // Reset hamburger
        hamburgerTop.style.transform = 'none';
        hamburgerTop.style.backgroundColor = 'var(--ink)';
        hamburgerMiddle.style.opacity = '1';
        hamburgerMiddle.style.transform = 'none';
        hamburgerBottom.style.transform = 'none';
        hamburgerBottom.style.backgroundColor = 'var(--ink)';

        // Hide backdrop
        backdrop.classList.add('opacity-0');
        backdrop.classList.remove('opacity-100', 'pointer-events-auto');
        backdrop.classList.add('pointer-events-none');
        button.setAttribute('aria-expanded', 'false');
        document.body.style.overflow = '';

        // Reset nav items
        navItems.forEach((item) => {
          item.style.opacity = '0';
          item.style.transform = 'translateY(20px)';
        });

        // Hide elements after transition
        setTimeout(() => {
          dropdown.classList.add('hidden');
          backdrop.classList.add('hidden');
        }, 300);
      }

      // Desktop nav indicator
      function initNavIndicator() {
        const navPill = document.querySelector('.nav-pill');
        if (!navPill) return;

        const indicator = document.getElementById('nav-indicator');
        const navLinks = navPill.querySelectorAll('.nav-link-desktop');
        const activeLink = navPill.querySelector('.nav-link-desktop.active');

        // Set initial position for active link
        if (activeLink && indicator) {
          const rect = activeLink.getBoundingClientRect();
          const parentRect = navPill.getBoundingClientRect();
          indicator.style.width = rect.width + 'px';
          indicator.style.left = (rect.left - parentRect.left) + 'px';
          indicator.style.opacity = '1';
        }

        // Hover effect
        navLinks.forEach(link => {
          link.addEventListener('mouseenter', () => {
            const rect = link.getBoundingClientRect();
            const parentRect = navPill.getBoundingClientRect();
            indicator.style.width = rect.width + 'px';
            indicator.style.left = (rect.left - parentRect.left) + 'px';
            indicator.style.opacity = '1';
          });
        });

        navPill.addEventListener('mouseleave', () => {
          if (activeLink) {
            const rect = activeLink.getBoundingClientRect();
            const parentRect = navPill.getBoundingClientRect();
            indicator.style.width = rect.width + 'px';
            indicator.style.left = (rect.left - parentRect.left) + 'px';
          } else {
            indicator.style.opacity = '0';
          }
        });
      }

      // Close menu when clicking on a navigation link
      document.addEventListener('DOMContentLoaded', function() {
        initNavIndicator();

        const mobileDropdown = document.getElementById('mobile-menu-dropdown');
        if (mobileDropdown) {
          mobileDropdown.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
              closeMobileMenu();
            }
          });
        }

        // Close menu on escape key
        document.addEventListener('keydown', function(e) {
          if (e.key === 'Escape' && isMenuOpen) {
            closeMobileMenu();
          }
        });
      });
    </script>
    """
  end
end
