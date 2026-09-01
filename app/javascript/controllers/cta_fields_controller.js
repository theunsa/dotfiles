import { Controller } from "@hotwired/stimulus"

// The admin CTA picker: relabels the shared value field for the kind on show,
// and hides what that kind has no use for — everything when the CTA is "none",
// the prefill when it is a phone call.
//
// Progressive enhancement: with JS off the fields stay visible with their
// generic server-rendered wording, and the form still saves the same values.
export default class extends Controller {
  static targets = ["kind", "fields", "value", "hint", "prefill"]

  static COPY = {
    whatsapp: { label: "WhatsApp number", placeholder: "+27821234567", hint: "Include the country code, like +27821234567" },
    phone:    { label: "Phone number", placeholder: "+27821234567", hint: "Include the country code, like +27821234567" },
    email:    { label: "Email address", placeholder: "you@example.com", hint: "The address replies go to." }
  }

  connect() {
    this.update()
  }

  update() {
    const kind = this.kindTarget.value
    this.fieldsTarget.hidden = kind === "none"
    if (kind === "none") return

    const copy = this.constructor.COPY[kind]
    this.labelFor(this.valueTarget).textContent = copy.label
    this.valueTarget.placeholder = copy.placeholder
    this.hintTarget.textContent = copy.hint
    this.prefillTarget.hidden = kind === "phone"
  }

  labelFor(field) {
    return this.element.querySelector(`label[for="${field.id}"]`)
  }
}
