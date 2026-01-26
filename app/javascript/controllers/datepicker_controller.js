import { Controller } from "@hotwired/stimulus"

// Wraps flatpickr (loaded via CDN in layout) for consistent date inputs.
export default class extends Controller {
  static values = {
    altFormat: { type: String, default: "d/m/Y" },
    dateFormat: { type: String, default: "Y-m-d" }
  }

  connect() {
    if (!window.flatpickr) return

    this.picker = flatpickr(this.element, {
      altInput: true,
      altFormat: this.altFormatValue,
      dateFormat: this.dateFormatValue,
      locale: (window.flatpickr && window.flatpickr.l10ns && window.flatpickr.l10ns.pt) || "pt",
      defaultDate: this.element.value || undefined,
      onReady: (_, __, instance) => {
        // Mirror the original input styling on the visible alt input.
        if (instance.altInput && this.element.className) {
          instance.altInput.className = this.element.className
        }
      }
    })
  }

  disconnect() {
    if (this.picker) this.picker.destroy()
  }
}
