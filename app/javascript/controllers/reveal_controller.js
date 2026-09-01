import { Controller } from "@hotwired/stimulus"

// Marks a brief's blocks — callout, steps, faq, cta — as they scroll into
// view, so motion.css can rise them into place. Body copy is deliberately not
// a target: a paragraph that has to animate before it can be read is slower
// than one that is simply there.
//
// The controller only reveals; the hiding is CSS, gated on the data-motion
// flag the layout sets pre-paint. Stamping motionReady here is what tells that
// script Stimulus made it, so the flag survives past its two-second failsafe.
export default class extends Controller {
  connect() {
    document.documentElement.dataset.motionReady = "1"
    if (document.documentElement.dataset.motion !== "on") return

    this.observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (!entry.isIntersecting) continue
          entry.target.dataset.revealed = ""
          // Arrival happens once. A block that re-animates every time it
          // crosses the fold turns re-reading into a light show.
          this.observer.unobserve(entry.target)
        }
      },
      // Fires a little before the block reaches the bottom edge, so it has
      // finished settling by the time the reader's eye gets there.
      { rootMargin: "0px 0px -10% 0px", threshold: 0.05 }
    )

    for (const block of this.element.querySelectorAll("[data-block]")) {
      this.observer.observe(block)
    }
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
