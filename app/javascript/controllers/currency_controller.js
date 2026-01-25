import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "hidden"]

  connect() {
    // Inicializa a máscara com o valor existente (edição)
    this.format()
  }

  format() {
    const raw = this.displayTarget.value || ""
    const digits = raw.replace(/\D/g, "")

    if (digits.length === 0) {
      this.hiddenTarget.value = ""
      this.displayTarget.value = ""
      return
    }

    const cents = parseInt(digits, 10)
    const value = cents / 100

    this.hiddenTarget.value = value.toFixed(2)
    this.displayTarget.value = new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(value)
  }
}
