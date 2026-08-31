import { Controller } from "@hotwired/stimulus"

// The admin markdown editor: insert-a-block chips and a live side-by-side
// preview. Deliberately not an editor library — a plain textarea plus this file.
//
// Progressive enhancement: the preview pane ships `hidden` and the split
// wrapper single-column; connect() reveals and widens them. With JS off the
// form is just a full-width textarea and the chips do nothing.
export default class extends Controller {
  static targets = ["textarea", "preview", "split"]
  static values = { previewUrl: String }

  connect() {
    this.previewTarget.hidden = false
    this.splitTarget.classList.add("editor-split")
    this.refresh()
  }

  disconnect() {
    clearTimeout(this.debounce)
    this.abort?.abort()
  }

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

    // A ```name fence only parses as a block when it sits alone on its line,
    // and one that lands mid-paragraph renders as literal text — so pad with
    // whatever blank lines the cursor position is missing.
    const lead = this.#padding(before, "end")
    const text = lead + snippet + this.#padding(after, "start")

    // insertText keeps the browser's native undo stack intact; assigning
    // textarea.value would wipe it, so a mis-clicked chip couldn't be undone.
    if (!document.execCommand("insertText", false, text)) {
      textarea.setRangeText(text, start, textarea.selectionEnd, "end")
    }

    this.#select(placeholder, start + lead.length)
    this.changed()
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

  // --- Live preview -------------------------------------------------------

  // Wired to the textarea's input event; debounced so a burst of typing costs
  // one render, not one per keystroke.
  changed() {
    clearTimeout(this.debounce)
    this.debounce = setTimeout(() => this.refresh(), 350)
  }

  async refresh() {
    this.abort?.abort()
    this.abort = new AbortController()
    this.previewTarget.setAttribute("aria-busy", "true")

    try {
      const response = await fetch(this.previewUrlValue, {
        method: "POST",
        signal: this.abort.signal,
        headers: {
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content,
          Accept: "text/html"
        },
        body: new URLSearchParams({ body_markdown: this.textareaTarget.value })
      })
      if (!response.ok) throw new Error(response.statusText)
      this.previewTarget.innerHTML = await response.text()
      this.previewTarget.removeAttribute("aria-busy")
    } catch (error) {
      // An aborted fetch means a newer render is on its way — keep aria-busy
      // and let it finish; anything else is a real failure worth showing.
      if (error.name === "AbortError") return
      this.previewTarget.textContent = "Could not render the preview. Your text is safe — keep typing or reload."
      this.previewTarget.removeAttribute("aria-busy")
    }
  }
}
