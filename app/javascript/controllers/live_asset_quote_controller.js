import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 15000 }
  }

  static targets = ["status", "price", "change", "time", "currency", "error"]

  connect() {
    this.fetchQuote()
    this.timer = setInterval(() => this.fetchQuote(), this.intervalValue)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  async fetchQuote() {
    this.setStatus("Atualizando...")
    try {
      const response = await fetch(this.urlValue, { headers: { Accept: "application/json" }, credentials: "same-origin" })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const quote = await response.json()
      this.renderQuote(quote)
      this.setStatus("Ao vivo")
      this.hideError()
    } catch (_error) {
      this.setStatus("Falha")
      this.showError("Não foi possível atualizar a cotação agora.")
    }
  }

  renderQuote(quote) {
    const currency = (quote.currency || "USD").toUpperCase()
    const price = Number(quote.market_price)
    const changePercent = Number(quote.change_percent)

    if (this.hasCurrencyTarget) this.currencyTarget.textContent = currency
    if (this.hasPriceTarget) this.priceTarget.textContent = this.formatCurrency(price, currency)
    if (this.hasChangeTarget) {
      this.changeTarget.textContent = Number.isNaN(changePercent) ? "-" : `${changePercent.toFixed(2)}%`
      this.changeTarget.classList.remove("text-emerald-600", "text-red-600", "dark:text-emerald-400", "dark:text-red-400")
      if (!Number.isNaN(changePercent)) {
        if (changePercent < 0) {
          this.changeTarget.classList.add("text-red-600", "dark:text-red-400")
        } else {
          this.changeTarget.classList.add("text-emerald-600", "dark:text-emerald-400")
        }
      }
    }

    if (this.hasTimeTarget) {
      const raw = quote.market_time
      if (!raw) {
        this.timeTarget.textContent = "-"
        return
      }
      const dt = new Date(raw)
      this.timeTarget.textContent = Number.isNaN(dt.getTime()) ? raw : dt.toLocaleString("pt-BR")
    }
  }

  formatCurrency(value, currency) {
    if (Number.isNaN(value)) return "-"
    return new Intl.NumberFormat("pt-BR", { style: "currency", currency }).format(value)
  }

  setStatus(text) {
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = text
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
