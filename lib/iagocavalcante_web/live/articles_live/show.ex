defmodule IagocavalcanteWeb.ArticlesLive.Show do
  use IagocavalcanteWeb, :live_view
  import IagocavalcanteWeb.Gettext

  alias Iagocavalcante.Blog

  def mount(%{"slug" => slug}, _session, socket) do
    {:ok, socket |> assign(:article, Blog.get_article_by_slug!(slug))}
  end

  def render(assigns) do
    ~H"""
    <div class="sm:px-8 mt-16 lg:mt-32">
      <div class="mx-auto max-w-7xl lg:px-8">
        <div class="relative px-4 sm:px-8 lg:px-12">
          <div class="mx-auto max-w-2xl lg:max-w-5xl">
            <div class="xl:relative">
              <div class="mx-auto max-w-2xl">
                <a
                  href="/articles"
                  type="button"
                  aria-label={gettext "Go back to articles"}
                  class="group mb-8 flex h-10 w-10 items-center justify-center rounded-full bg-white shadow-md shadow-zinc-800/5 ring-1 ring-zinc-900/5 transition dark:border dark:border-zinc-700/50 dark:bg-zinc-800 dark:ring-0 dark:ring-white/10 dark:hover:border-zinc-700 dark:hover:ring-white/20 lg:absolute lg:-left-5 lg:mb-0 lg:-mt-2 xl:-top-1.5 xl:left-0 xl:mt-0"
                >
                  <svg
                    viewBox="0 0 16 16"
                    fill="none"
                    aria-hidden="true"
                    class="h-4 w-4 stroke-zinc-500 transition group-hover:stroke-zinc-700 dark:stroke-zinc-500 dark:group-hover:stroke-zinc-400"
                  >
                    <path
                      d="M7.25 11.25 3.75 8m0 0 3.5-3.25M3.75 8h8.5"
                      stroke-width="1.5"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                    >
                    </path>
                  </svg>
                </a>
                <article>
                  <header class="flex flex-col">
                    <h1 class="mt-6 text-4xl font-bold tracking-tight text-zinc-800 dark:text-zinc-100 sm:text-5xl">
                      <%= @article.title %>
                    </h1>
                    <time
                      datetime="2022-09-05"
                      class="order-first flex items-center text-base text-zinc-400 dark:text-zinc-500"
                    >
                      <span class="h-4 w-0.5 rounded-full bg-zinc-200 dark:bg-zinc-500"></span><span class="ml-3">September 5, 2022</span>
                    </time>
                  </header>
                  <div class="mt-8 prose dark:prose-invert">
                    <p>
                      Most companies try to stay ahead of the curve when it comes to visual design, but for Planetaria we needed to create a brand that would still inspire us 100 years from now when humanity has spread across our entire solar system.
                    </p>
                    <img
                      alt=""
                      srcset="/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Fplanetaria-design-system.d4cfce90.png&amp;w=1920&amp;q=75 1x, /_next/image?url=%2F_next%2Fstatic%2Fmedia%2Fplanetaria-design-system.d4cfce90.png&amp;w=3840&amp;q=75 2x"
                      src="/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Fplanetaria-design-system.d4cfce90.png&amp;w=3840&amp;q=75"
                      decoding="async"
                      data-nimg="1"
                      loading="lazy"
                      style="color: transparent;"
                      width="1310"
                      height="872"
                    />
                    <p>
                      I knew that to get it right I was going to have to replicate the viewing conditions of someone from the future, so I grabbed my space helmet from the closet, created a new Figma document, and got to work.
                    </p>
                    <h2>Sermone fata</h2>
                    <p>Lorem markdownum, bracchia in redibam! Terque unda puppi nec, linguae posterior
                      in utraque respicere candidus Mimasque formae; quae conantem cervice. Parcite
                      variatus, redolentia adeunt. Tyrioque dies, naufraga sua adit partibus celanda
                      torquere temptata, erit maneat et ramos, <a href="#">iam</a> ait dominari
                      potitus! Tibi litora matremque fumantia condi radicibus opusque.</p>
                    <p>Deus feram verumque, fecit, ira tamen, terras per alienae victum. Mutantur
                      levitate quas ubi arcum ripas oculos abest. Adest <a href="#">commissaque
                        victae</a> in gemitus nectareis ire diva
                      dotibus ora, et findi huic invenit; fatis? Fractaque dare superinposita
                      nimiumque simulatoremque sanguine, at voce aestibus diu! Quid veterum hausit tu
                      nil utinam paternos ima, commentaque.</p>
                    <pre class="language-c"><code class="language-c">exbibyte_wins <span class="token operator">=</span> <span class="token function">gigahertz</span><span class="token punctuation">(</span><span class="token number">3</span><span class="token punctuation">)</span><span class="token punctuation">;</span>
    grayscaleUtilityClient <span class="token operator">=</span> control_uat<span class="token punctuation">;</span>
    pcmciaHibernate <span class="token operator">=</span> <span class="token function">oop_virus_console</span><span class="token punctuation">(</span>text_mountain<span class="token punctuation">)</span><span class="token punctuation">;</span>
    <span class="token keyword">if</span> <span class="token punctuation">(</span>stateWaisFirewire <span class="token operator">&gt;=</span> <span class="token operator">-</span><span class="token number">2</span><span class="token punctuation">)</span> <span class="token punctuation">{</span>
    jfs <span class="token operator">=</span> <span class="token number">647065</span> <span class="token operator">/</span> <span class="token function">ldapVrml</span><span class="token punctuation">(</span>tutorialRestore<span class="token punctuation">,</span> <span class="token number">85</span><span class="token punctuation">)</span><span class="token punctuation">;</span>
    metal_runtime_parse <span class="token operator">=</span> roomComputingResolution <span class="token operator">-</span> toolbarUpload <span class="token operator">+</span>
            ipx_nvram_open<span class="token punctuation">;</span>
    <span class="token punctuation">}</span> <span class="token keyword">else</span> <span class="token punctuation">{</span>
    maximizeSidebar <span class="token operator">*=</span> <span class="token function">suffix_url</span><span class="token punctuation">(</span>flatbed <span class="token operator">+</span> <span class="token number">2</span><span class="token punctuation">,</span> requirements_encoding_node <span class="token operator">+</span>
            only_qbe_media<span class="token punctuation">,</span> minicomputer<span class="token punctuation">)</span><span class="token punctuation">;</span>
    <span class="token punctuation">}</span>
    </code></pre>
                    <p>Aere repetiti cognataque natus. Habebat vela solutis saepe munus nondum adhuc
                      oscula nomina pignora corpus deserat.</p>
                    <h2>Lethaei Pindumve me quae dinumerat Pavor</h2>
                    <p>Idem se saxa fata pollentibus geminos; quos pedibus. Est urnis Herses omnes nec
                      divite: et ille illa furit sim verbis Cyllenius.</p>
                    <ol>
                      <li>Captus inpleverunt collo</li>
                      <li>Nec nam placebant</li>
                      <li>Siquos vulgus</li>
                      <li>Dictis carissime fugae</li>
                      <li>A tacitos nulla viginti</li>
                    </ol>
                    <p>
                      Ungues fistula annoso, ille addit linoque motatque uberior verso
                      <a href="#">rubuerunt</a> confine desuetaque. <em>Sanguine</em>
                      anteit
                      emerguntque expugnacior est pennas iniqui ecce <strong>haeret</strong>
                      genus: peiora imagine
                      fossas Cephisos formosa! Refugitque amata <a href="#">refelli</a>
                      supplex. Summa brevis vetuere tenebas, hostes vetantis, suppressit, arreptum
                      regna. Postquam conpescit iuvenis habet corpus, et erratica, perdere, tot mota
                      ars talis.
                    </p>
                    <pre class="language-c"><code class="language-c">digital<span class="token punctuation">.</span>webcam_dual_frequency <span class="token operator">=</span> webmasterMms<span class="token punctuation">;</span>
    <span class="token keyword">if</span> <span class="token punctuation">(</span><span class="token number">5</span> <span class="token operator">+</span> language_standalone_google<span class="token punctuation">)</span> <span class="token punctuation">{</span>
    cc_inbox_layout <span class="token operator">*=</span> file_character<span class="token punctuation">;</span>
    task <span class="token operator">+=</span> p<span class="token punctuation">;</span>
    lockUnicode <span class="token operator">+=</span> <span class="token function">enterprise_monochrome</span><span class="token punctuation">(</span>tokenFunctionPersonal<span class="token punctuation">,</span> keyVirtual<span class="token punctuation">,</span>
            adf<span class="token punctuation">)</span><span class="token punctuation">;</span>
    <span class="token punctuation">}</span>
    <span class="token function">windows_binary_esports</span><span class="token punctuation">(</span><span class="token number">87734</span><span class="token punctuation">,</span> <span class="token function">array</span><span class="token punctuation">(</span>restoreRomTopology<span class="token punctuation">,</span> <span class="token function">adRaw</span><span class="token punctuation">(</span><span class="token number">407314</span><span class="token punctuation">)</span><span class="token punctuation">,</span>
        dongleBashThumbnail<span class="token punctuation">)</span><span class="token punctuation">,</span> interpreter<span class="token punctuation">)</span><span class="token punctuation">;</span>
    </code></pre>
                    <p>Sit volat naturam; motu Cancri. Erat pro simul quae valuit quoque timorem quam
                      proelia: illo patrio <em>esse summus</em>, enim sua serpentibus, Hyleusque. Est coniuge
                      recuso; refert Coroniden ignotos manat, adfectu.</p>
                  </div>
                </article>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
