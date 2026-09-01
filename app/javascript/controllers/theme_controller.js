import { Controller } from "@hotwired/stimulus"

// The client-facing light/dark switch. The choice lives in localStorage so it
// survives navigation and return visits; with nothing stored the page keeps
// following the device's own preference.
//
// Progressive enhancement: the button ships hidden and is only revealed here,
// so a client with JS off never sees a control that cannot do anything. The
// pre-paint script in the layout applies the stored choice before first paint.
export default class extends Controller {
  static KEY = "brief.theme"

  connect() {
    this.element.hidden = false
    this.reflect()
  }

  toggle() {
    const dark = !this.dark
    this.crossfade()
    document.documentElement.classList.toggle("dark", dark)
    try {
      localStorage.setItem(this.constructor.KEY, dark ? "dark" : "light")
    } catch (error) {
      // Private browsing can refuse writes; the switch still works for this page.
    }
    this.reflect()
  }

  // Every token swaps at once, which lands as a hard cut. The transition is
  // switched on for the length of the swap and then off again, so scrolling and
  // hovering elsewhere never pay for a rule that exists for this one moment.
  crossfade() {
    const root = document.documentElement
    root.classList.add("theme-switching")
    clearTimeout(this.crossfadeTimer)
    this.crossfadeTimer = setTimeout(() => root.classList.remove("theme-switching"), 260)
  }

  disconnect() {
    clearTimeout(this.crossfadeTimer)
    document.documentElement.classList.remove("theme-switching")
  }

  reflect() {
    this.element.setAttribute(
      "aria-label",
      this.dark ? "Switch to light theme" : "Switch to dark theme"
    )

    // The browser chrome is tinted to match the page background; the layout sets
    // it before first paint, and this keeps it honest after a switch.
    const meta = document.querySelector('meta[name="theme-color"]')
    if (meta) meta.content = this.dark ? "#0c0a09" : "#ffffff"
  }

  get dark() {
    return document.documentElement.classList.contains("dark")
  }
}
