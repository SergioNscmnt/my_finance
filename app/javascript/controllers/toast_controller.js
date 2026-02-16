import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "progress"]
  static values = { delay: { type: Number, default: 3000 } }

  connect() {
    if (this.hasProgressTarget) {
      this.progressTarget.style.width = "0%"
      this.progressTarget.style.transition = `width ${this.delayValue}ms linear`
      requestAnimationFrame(() => {
        this.progressTarget.style.width = "100%"
      })
    }

    this.hideTimeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.hideTimeout)
    clearTimeout(this.removeTimeout)
  }

  dismiss() {
    if (!this.hasContentTarget) {
      this.element.remove()
      return
    }

    this.contentTarget.style.opacity = "0"
    this.contentTarget.style.transform = "translateY(-8px)"
    if (this.hasProgressTarget) {
      this.progressTarget.style.width = "100%"
    }
    this.removeTimeout = setTimeout(() => this.element.remove(), 300)
  }
}
