import { Controller } from "@hotwired/stimulus"

// The phone-only sticky CTA. It stays out of the way until the reader is
// actually into the document — a button asking for the sale before a word has
// been read is pushy — and steps aside again while the in-page CTA card is on
// screen, so the same button is never offered twice at once.
//
// If motion is off (reduced-motion, or JS that never booted) none of the CSS
// that hides this bar applies, and it simply sits there as it always did.
export default class extends Controller {
  static values = { after: { type: Number, default: 0.25 } }

  connect() {
    document.documentElement.dataset.motionReady = "1"
    if (document.documentElement.dataset.motion !== "on") return

    this.scrolled = false
    this.cardVisible = false

    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.onScroll()

    // The in-page card lives outside this element, so it is found by anchor
    // rather than by Stimulus target.
    const card = document.querySelector("[data-cta-anchor]")
    if (card) {
      this.observer = new IntersectionObserver(
        ([entry]) => {
          this.cardVisible = entry.isIntersecting
          this.reflect()
        },
        { threshold: 0 }
      )
      this.observer.observe(card)
    }
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    this.observer?.disconnect()
  }

  onScroll() {
    const scrollable = document.documentElement.scrollHeight - window.innerHeight
    // A brief short enough not to scroll has no "read a bit first" moment to
    // wait for, so the bar is offered straight away.
    const progress = scrollable > 0 ? window.scrollY / scrollable : 1
    const scrolled = progress >= this.afterValue

    if (scrolled === this.scrolled) return
    this.scrolled = scrolled
    this.reflect()
  }

  reflect() {
    if (this.scrolled && !this.cardVisible) {
      this.element.dataset.visible = ""
    } else {
      delete this.element.dataset.visible
    }
  }
}
