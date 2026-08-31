import { Controller } from "@hotwired/stimulus"

// The admin markdown editor: insert-a-block chips and an Edit/Preview toggle.
// Deliberately not an editor library — a plain textarea plus this file.
export default class extends Controller {
  static targets = ["textarea", "preview", "editTab", "previewTab"]
  static values = { previewUrl: String }

  // --- Inserting a block -------------------------------------------------

  insert(event) {
    event.preventDefault()

    const { placeholder } = event.currentTarget.dataset
    // Trailing newline trimmed so the snippet's own line break doesn't stack
    // with the padding below and leave three blank lines behind the block.
    const snippet = event.currentTarget.dataset.snippet.replace(/\n+$/, "")
    const textarea = this.textareaTarget
    textarea.focus()

    const start = textarea.selectionStart
    const before = textarea.value.slice(0, start)
    const after = textarea.value.slice(textarea.selectionEnd)

    // `::name` only parses as a block when it sits alone on its line, and a
    // block that lands mid-paragraph renders as plain text with no error at
    // all — so pad with whatever blank lines the cursor position is missing.
    const lead = this.#padding(before, "end")
    const text = lead + snippet + this.#padding(after, "start")

    // insertText keeps the browser's native undo stack intact; assigning
    // textarea.value would wipe it, so a mis-clicked chip couldn't be undone.
    if (!document.execCommand("insertText", false, text)) {
      textarea.setRangeText(text, start, textarea.selectionEnd, "end")
    }

    this.#select(placeholder, start + lead.length)
  }

  // Blank lines needed between the cursor and the text already on that side.
  #padding(text, edge) {
    if (text === "") return ""
    const touches = (s) => (edge === "end" ? text.endsWith(s) : text.startsWith(s))
    if (touches("\n\n")) return ""
    return touches("\n") ? "\n" : "\n\n"
  }

  // Highlight the snippet's example text so typing replaces it.
  #select(placeholder, from) {
    if (!placeholder) return
    const at = this.textareaTarget.value.indexOf(placeholder, from)
    if (at !== -1) this.textareaTarget.setSelectionRange(at, at + placeholder.length)
  }

  // --- Edit / Preview ----------------------------------------------------

  showEdit(event) {
    event?.preventDefault()
    this.#tab(false)
    this.textareaTarget.focus()
  }

  async showPreview(event) {
    event?.preventDefault()
    this.#tab(true)
    this.previewTarget.setAttribute("aria-busy", "true")

    try {
      const response = await fetch(this.previewUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content,
          Accept: "text/html"
        },
        body: new URLSearchParams({ body_markdown: this.textareaTarget.value })
      })
      if (!response.ok) throw new Error(response.statusText)
      this.previewTarget.innerHTML = await response.text()
    } catch {
      this.previewTarget.textContent = "Could not render the preview. Your text is safe — switch back to Edit."
    } finally {
      this.previewTarget.removeAttribute("aria-busy")
    }
  }

  #tab(previewing) {
    this.textareaTarget.hidden = previewing
    this.previewTarget.hidden = !previewing
    this.editTabTarget.setAttribute("aria-selected", String(!previewing))
    this.previewTabTarget.setAttribute("aria-selected", String(previewing))
  }
}
