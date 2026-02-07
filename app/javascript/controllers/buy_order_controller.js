import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "total"]
  static values = { price: Number }

  connect() {
    this.recalculate()
  }

  recalculate() {
    const quantity = parseFloat(this.quantityTarget.value || "0")
    const total = quantity * this.priceValue
    this.totalTarget.textContent = new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(isFinite(total) ? total : 0)
  }
}
