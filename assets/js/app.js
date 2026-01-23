// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// App version - changing this forces browser to fetch new JS
const APP_VERSION = "2026.01.23.4"

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import darkModeHook from "../vendor/dark-mode"
import { VisualEditor } from "./visual_editor"

let Hooks = {}
Hooks.DarkThemeToggle = darkModeHook
Hooks.VisualEditor = VisualEditor

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Custom logger to catch LiveView errors and auto-reload on session issues
const liveViewLogger = (kind, msg, data) => {
  if (kind === "error") {
    console.error(`LiveView ${kind}:`, msg, data)
    // Check for session/topic errors that require reload
    const errorStr = JSON.stringify(data) + msg
    if (errorStr.includes("unmatched topic") || errorStr.includes("stale") || errorStr.includes("unauthorized")) {
      console.log("LiveView session invalid, reloading page...")
      window.location.reload()
    }
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
  logger: liveViewLogger
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.delayedShow(200))
window.addEventListener("phx:page-loading-stop", info => topbar.hide())


// Handle locale persistence - set cookie when locale changes
window.addEventListener("phx:set-locale", (event) => {
  const locale = event.detail.locale
  const cookieName = "phxi18nexamplelanguage"
  // Set cookie for 1 year
  document.cookie = `${cookieName}=${locale}; path=/; max-age=31536000; SameSite=Lax`
})

// connect if there are any LiveViews on the page
liveSocket.connect()
console.log(`LiveView app loaded, version: ${APP_VERSION}`)

// Handle LiveView connection errors (e.g., after deployment)
// "unmatched topic" means the server doesn't recognize our session - reload to fix
let reloadScheduled = false
window.addEventListener("phx:page-loading-start", () => {
  // If loading takes more than 5 seconds, something is wrong - reload
  if (!reloadScheduled) {
    reloadScheduled = true
    setTimeout(() => {
      if (reloadScheduled) {
        console.log("Page loading timeout, reloading...")
        window.location.reload()
      }
    }, 5000)
  }
})
window.addEventListener("phx:page-loading-stop", () => {
  reloadScheduled = false
})

// Intercept console.error to catch LiveView push errors
let isReloading = false
const originalConsoleError = console.error
console.error = function(...args) {
  originalConsoleError.apply(console, args)
  const message = args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' ')
  if (!isReloading && (message.includes('unmatched topic') || message.includes('Failed to push'))) {
    isReloading = true
    console.log("LiveView session error detected, reloading now...")
    window.location.reload()
  }
}

// Catch any uncaught errors related to LiveView session issues
window.onerror = function(message, source, lineno, colno, error) {
  const errorStr = String(message) + String(error)
  if (errorStr.includes('unmatched topic') || errorStr.includes('Failed to push')) {
    console.log("Uncaught LiveView error, reloading...")
    window.location.reload()
    return true
  }
  return false
}

// Handle LiveView connection errors (e.g., after deployment)
// "unmatched topic" means the server doesn't recognize our session - reload to fix
liveSocket.socket.onError((error) => {
  if (error && error.reason === "unmatched topic") {
    console.log("LiveView session expired, reloading page...")
    window.location.reload()
  }
})

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
