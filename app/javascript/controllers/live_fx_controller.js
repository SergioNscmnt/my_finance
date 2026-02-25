import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 15000 }
  }

  static targets = ["status", "updatedAt", "list", "template", "error"]

  connect() {
    this.fetchRates()
    this.timer = setInterval(() => this.fetchRates(), this.intervalValue)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  async fetchRates() {
    try {
      this.setStatus("Atualizando...")
      const response = await fetch(this.urlValue, {
        headers: { Accept: "application/json" },
        credentials: "same-origin"
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      const payload = await response.json()
      this.renderRates(payload)
      this.setStatus("Ao vivo")
      this.hideError()
    } catch (_error) {
      this.setStatus("Falha na atualização")
      this.showError("Não foi possível atualizar cotações agora.")
    }
  }

  renderRates(payload) {
    if (!this.hasListTarget || !this.hasTemplateTarget) return
    const rates = Array.isArray(payload.rates) ? payload.rates : []
    this.listTarget.innerHTML = ""

    rates.forEach((entry) => {
      const fragment = this.templateTarget.content.cloneNode(true)
      fragment.querySelector("[data-field='pair']").textContent = `${payload.base}/${entry.symbol}`
      fragment.querySelector("[data-field='rate']").textContent = this.formatRate(entry.rate)
      fragment.querySelector("[data-field='inverse']").textContent = this.formatRate(entry.inverse_rate)
      this.listTarget.appendChild(fragment)
    })

    if (payload.updated_at && this.hasUpdatedAtTarget) {
      const timestamp = new Date(payload.updated_at)
      const formatted = Number.isNaN(timestamp.getTime())
        ? payload.updated_at
        : timestamp.toLocaleTimeString("pt-BR")
      this.updatedAtTarget.textContent = `Última atualização: ${formatted}`
    }
  }

  formatRate(value) {
    const number = Number(value)
    if (Number.isNaN(number)) return "-"
    return new Intl.NumberFormat("pt-BR", {
      minimumFractionDigits: 4,
      maximumFractionDigits: 6
    }).format(number)
  }

  setStatus(message) {
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = message
  }

  showError(message) {
    if (!this.hasErrorTarget) return
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }

  hideError() {
    if (!this.hasErrorTarget) return
    this.errorTarget.classList.add("hidden")
  }
}
