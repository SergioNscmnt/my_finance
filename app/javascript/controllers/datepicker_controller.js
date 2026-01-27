import { Controller } from "@hotwired/stimulus"

// Wraps flatpickr (loaded via CDN in layout) for consistent date inputs.
export default class extends Controller {
  static values = {
    altFormat: { type: String, default: "d/m/Y" },
    dateFormat: { type: String, default: "Y-m-d" }
  }

  connect() {
    if (!window.flatpickr) {
      this.attachMask(this.element)
      return
    }

    this.picker = flatpickr(this.element, {
      altInput: true,
      altFormat: this.altFormatValue,
      dateFormat: this.dateFormatValue,
      allowInput: true,
      locale: (window.flatpickr && window.flatpickr.l10ns && window.flatpickr.l10ns.pt) || "pt",
      defaultDate: this.element.value || undefined,
      onReady: (_, __, instance) => {
        // Mirror the original input styling on the visible alt input.
        if (instance.altInput && this.element.className) {
          instance.altInput.className = this.element.className
        }
        if (instance.altInput) {
          this.attachMask(instance.altInput)
        }
      }
    })
  }

  disconnect() {
    if (this.maskedInput) {
      this.maskedInput.removeEventListener("input", this.handleMask)
    }
    if (this.picker) this.picker.destroy()
  }

  attachMask(input) {
    this.maskedInput = input
    this.handleMask = (event) => {
      const raw = event.target.value.replace(/\D/g, "").slice(0, 8)
      const parts = []
      if (raw.length > 0) parts.push(raw.slice(0, 2))
      if (raw.length > 2) parts.push(raw.slice(2, 4))
      if (raw.length > 4) parts.push(raw.slice(4, 8))
      event.target.value = parts.join("/")
    }
    input.setAttribute("inputmode", "numeric")
    input.setAttribute("placeholder", "dd/mm/aaaa")
    input.addEventListener("input", this.handleMask)
  }
}
