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
    document.documentElement.classList.toggle("dark", dark)
    try {
      localStorage.setItem(this.constructor.KEY, dark ? "dark" : "light")
    } catch (error) {
      // Private browsing can refuse writes; the switch still works for this page.
    }
    this.reflect()
  }

  reflect() {
    this.element.setAttribute(
      "aria-label",
      this.dark ? "Switch to light theme" : "Switch to dark theme"
    )
  }

  get dark() {
    return document.documentElement.classList.contains("dark")
  }
}
