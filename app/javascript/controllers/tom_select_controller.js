import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!window.TomSelect) return
    if (this.element.tomselect) return

    const placeholder = this.element.dataset.placeholder || ""

    this.tom = new TomSelect(this.element, {
      placeholder: placeholder,
      allowEmptyOption: true,
      create: false,
      plugins: ["dropdown_input"],
      render: {
        option: (data, escape) => {
          if (!data.value) return `<div class="option">${escape(data.text)}</div>`
          const kind = data.kind
          const badgeClass = kind === "expense" ? "badge-expense" : "badge-income"
          const label = kind === "expense" ? "Despesa" : kind === "income" ? "Receita" : ""
          const badge = label ? `<span class="badge ${badgeClass}">${label}</span>` : ""
          return `<div class="option option-item"><span>${escape(data.text)}</span>${badge}</div>`
        }
      }
    })
  }

  disconnect() {
    if (this.tom) this.tom.destroy()
  }
}
