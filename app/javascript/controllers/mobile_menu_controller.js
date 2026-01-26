import { Controller } from "@hotwired/stimulus"

// Simple mobile menu toggle for the top nav.
export default class extends Controller {
  static targets = ["panel", "iconOpen", "iconClose"]

  toggle() {
    const isOpen = !this.panelTarget.classList.contains("hidden")
    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.panelTarget.classList.add("flex")
    this.iconOpenTarget.classList.toggle("hidden")
    this.iconCloseTarget.classList.toggle("hidden")
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this.panelTarget.classList.remove("flex")
    this.iconOpenTarget.classList.remove("hidden")
    this.iconCloseTarget.classList.add("hidden")
  }
}
