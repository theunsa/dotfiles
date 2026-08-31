import { Controller } from "@hotwired/stimulus"

// Replaces Turbo's window.confirm (which shows browser chrome — "localhost says
// …") with the vendored alert-dialog. Attached to the <dialog> in the layout;
// every data-turbo-confirm on the page routes through it.
export default class extends Controller {
  static targets = ["message", "accept"]

  connect() {
    const confirmMethod = (message, _element, submitter) => {
      this.messageTarget.textContent = message

      // Take the trigger's tone, so a destructive action's confirm button reads
      // as destructive too rather than as a neutral OK.
      // Deleted, not blanked: the theme styles a default button with
      // `.btn:not([data-variant])`, so an empty data-variant leaves it unstyled.
      const destructive = submitter?.dataset?.variant === "destructive"
      if (destructive) {
        this.acceptTarget.dataset.variant = "destructive"
      } else {
        delete this.acceptTarget.dataset.variant
      }
      this.acceptTarget.textContent = destructive ? "Delete" : "Continue"

      this.element.showModal()
      this.acceptTarget.focus()
      return new Promise((resolve) => (this.resolve = resolve))
    }

    // Turbo 8 moved this onto config; setConfirmMethod still works but warns.
    if (Turbo.config?.forms) {
      Turbo.config.forms.confirm = confirmMethod
    } else {
      Turbo.setConfirmMethod(confirmMethod)
    }
  }

  accept() {
    this.element.close("accept")
  }

  cancel() {
    this.element.close("cancel")
  }

  // Fires for the buttons above and for Escape, which leaves returnValue empty
  // — so anything that isn't an explicit accept resolves as "no".
  closed() {
    this.resolve?.(this.element.returnValue === "accept")
    this.resolve = null
    this.element.returnValue = ""
  }
}
