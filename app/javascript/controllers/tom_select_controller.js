import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!window.TomSelect) return
    if (this.element.tomselect) return

    const placeholder = this.element.dataset.placeholder || ""
    const remoteUrl = this.element.dataset.remoteUrl

    const config = {
      placeholder: placeholder,
      allowEmptyOption: true,
      create: false,
      plugins: ["dropdown_input"],
      render: {
        option: (data, escape) => {
          if (!data.value) return `<div class="option">${escape(data.text)}</div>`
          const kind = data.kind || data.asset_type
          const badgeClass = kind === "expense" ? "badge-expense" : "badge-income"
          const label = kind === "expense" ? "Despesa" : kind === "income" ? "Receita" : (kind || "").toString().toUpperCase()
          const badge = label ? `<span class="badge ${badgeClass}">${label}</span>` : ""
          return `<div class="option option-item"><span>${escape(data.text)}</span>${badge}</div>`
        }
      }
    }

    if (remoteUrl) {
      config.plugins = ["dropdown_input", "virtual_scroll"]
      config.valueField = "value"
      config.labelField = "text"
      config.searchField = ["ticker", "name", "text"]
      config.preload = true
      config.loadThrottle = 250
      config.maxOptions = 30
      config.firstUrl = (query) => `${remoteUrl}?q=${encodeURIComponent(query || "")}&page=1&per_page=30`
      config.load = function(query, callback) {
        const url = this.getUrl(query)
        if (!url) {
          callback()
          return
        }

        fetch(url, { headers: { Accept: "application/json" } })
          .then((response) => response.ok ? response.json() : { items: [], pagination: {} })
          .then((json) => {
            const nextPage = json?.pagination?.next_page
            const nextUrl = nextPage ? `${remoteUrl}?q=${encodeURIComponent(query || "")}&page=${nextPage}&per_page=30` : null
            this.setNextUrl(query, nextUrl)
            callback(json.items || [])
          })
          .catch(() => callback())
      }
    }

    this.tom = new TomSelect(this.element, config)
  }

  disconnect() {
    if (this.tom) this.tom.destroy()
  }
}
