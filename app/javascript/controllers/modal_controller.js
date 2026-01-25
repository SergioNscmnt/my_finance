import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "container", "frame", "panel"]
  static classes = ["open"]

  connect() {
    this.close = this.close.bind(this)
    document.addEventListener("keydown", this.handleEscape)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleEscape)
  }

  handleEscape = (event) => {
    if (event.key === "Escape") this.close()
  }

  open() {
    this.backdropTarget.classList.remove("hidden")
    this.containerTarget.classList.remove("hidden")
    this.element.classList.add(this.openClass)
  }

  close() {
    this.backdropTarget.classList.add("hidden")
    this.containerTarget.classList.add("hidden")
    this.element.classList.remove(this.openClass)
    this.clearFrame()
  }

  handleSubmit(event) {
    const { fetchResponse } = event.detail
    if (!fetchResponse) return

    // Em erro de validação (422), mantém modal aberto para corrigir
    if (fetchResponse.response.status === 422) {
      this.open()
      return
    }

    // Em sucesso (2xx) ou redirect, deixa Turbo navegar (possivelmente _top) e fecha modal
    if (fetchResponse.response.ok || fetchResponse.response.redirected) {
      this.close()
    }
  }

  clearFrame() {
    // Remove conteúdo para evitar estados antigos
    this.frameTarget.innerHTML = "<!-- modal cleared -->"
    this.frameTarget.removeAttribute("src")
  }
}
