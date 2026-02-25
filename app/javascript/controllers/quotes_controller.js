import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    assetIds: Array,
    pollIntervalActive: { type: Number, default: 5000 },
    pollIntervalBackground: { type: Number, default: 30000 }
  }

  connect() {
    this.fetchInFlight = false
    this.handleVisibilityOrFocus = this.handleVisibilityOrFocus.bind(this)
    this.handleOnline = this.handleOnline.bind(this)
    this.handleOffline = this.handleOffline.bind(this)

    document.addEventListener("visibilitychange", this.handleVisibilityOrFocus)
    window.addEventListener("focus", this.handleVisibilityOrFocus)
    window.addEventListener("blur", this.handleVisibilityOrFocus)
    window.addEventListener("online", this.handleOnline)
    window.addEventListener("offline", this.handleOffline)

    if (this.shouldPausePolling()) return

    this.fetchQuotes()
    this.scheduleNextPoll()
  }

  disconnect() {
    this.clearTimer()
    document.removeEventListener("visibilitychange", this.handleVisibilityOrFocus)
    window.removeEventListener("focus", this.handleVisibilityOrFocus)
    window.removeEventListener("blur", this.handleVisibilityOrFocus)
    window.removeEventListener("online", this.handleOnline)
    window.removeEventListener("offline", this.handleOffline)
  }

  handleVisibilityOrFocus() {
    if (this.shouldPausePolling()) {
      this.clearTimer()
      return
    }

    this.fetchQuotes()
    this.scheduleNextPoll()
  }

  handleOnline() {
    this.fetchQuotes()
    this.scheduleNextPoll()
  }

  handleOffline() {
    this.clearTimer()
  }

  shouldPausePolling() {
    return document.visibilityState === "hidden" || !navigator.onLine
  }

  pollingInterval() {
    return document.hasFocus() ? this.pollIntervalActiveValue : this.pollIntervalBackgroundValue
  }

  scheduleNextPoll() {
    this.clearTimer()

    if (this.shouldPausePolling()) return

    this.timer = setTimeout(() => {
      this.fetchQuotes()
      this.scheduleNextPoll()
    }, this.pollingInterval())
  }

  clearTimer() {
    if (!this.timer) return
    clearTimeout(this.timer)
    this.timer = null
  }

  async fetchQuotes() {
    if (this.fetchInFlight || this.shouldPausePolling()) return

    const assetIds = this.assetIdsValue || []
    if (assetIds.length === 0) return

    this.fetchInFlight = true

    try {
      const query = new URLSearchParams({ asset_ids: assetIds.join(",") }).toString()
      const response = await fetch(`${this.urlValue}?${query}`, {
        method: "GET",
        headers: { Accept: "application/json" },
        credentials: "same-origin"
      })

      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const payload = await response.json()
      this.renderQuotes(payload)
    } catch (_error) {
      // noop: UI mantém último estado conhecido.
    } finally {
      this.fetchInFlight = false
    }
  }

  renderQuotes(payload) {
    const quotes = Array.isArray(payload.quotes) ? payload.quotes : []

    quotes.forEach((quote) => {
      const row = this.element.querySelector(`[data-quote-asset-id='${quote.asset_id}']`)
      if (!row) return

      this.renderField(row, "price", this.formatCurrency(quote.price, row.dataset.quoteCurrency || "BRL"))
      this.renderField(row, "change", this.formatChange(quote.change_percent))
      this.renderField(row, "updated", this.formatUpdatedAt(quote.retrieved_at))
      this.renderField(row, "stale", quote.stale ? "Desatualizado" : "Atualizado")

      row.classList.toggle("is-stale", !!quote.stale)
      row.dataset.quoteStale = quote.stale ? "true" : "false"
    })
  }

  renderField(row, field, value) {
    const node = row.querySelector(`[data-quote-field='${field}']`)
    if (!node) return
    node.textContent = value

    if (field === "change") {
      const number = Number(value.replace(/[\.%\s]/g, "").replace(",", "."))
      node.classList.remove("text-emerald-600", "text-red-600", "dark:text-emerald-400", "dark:text-red-400")
      if (Number.isNaN(number)) return
      if (number < 0) {
        node.classList.add("text-red-600", "dark:text-red-400")
      } else {
        node.classList.add("text-emerald-600", "dark:text-emerald-400")
      }
    }
  }

  formatCurrency(value, currency) {
    const number = Number(value)
    if (Number.isNaN(number)) return "-"

    return new Intl.NumberFormat("pt-BR", { style: "currency", currency }).format(number)
  }

  formatChange(value) {
    const number = Number(value)
    if (Number.isNaN(number)) return "-"

    return `${number.toFixed(2)}%`
  }

  formatUpdatedAt(value) {
    if (!value) return "-"

    const timestamp = new Date(value)
    if (Number.isNaN(timestamp.getTime())) return value

    return timestamp.toLocaleTimeString("pt-BR")
  }
}
