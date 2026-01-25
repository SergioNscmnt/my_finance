import { Controller } from "@hotwired/stimulus"

// Fecha <details> ao clicar em um item interno (evita menu aberto após ação Turbo)
export default class extends Controller {
  close(event) {
    const details = this.element.closest("details")
    if (details) details.removeAttribute("open")
  }
}
