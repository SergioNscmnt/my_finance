import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]
  static values = { previewUrl: String }

  connect() {
    this.closeOnOutsideClick = (event) => {
      if (!this.element.contains(event.target)) this.hide()
    }
    document.addEventListener("click", this.closeOnOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
    clearTimeout(this.timeout)
    if (this.abortController) this.abortController.abort()
  }

  queue() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.search(), 180)
  }

  handleKeydown(event) {
    if (event.key === "Escape") this.hide()
  }

  search() {
    const query = this.inputTarget.value.trim()
    if (query.length < 2) {
      this.hide()
      return
    }

    if (this.abortController) this.abortController.abort()
    this.abortController = new AbortController()

    const url = new URL(this.previewUrlValue, window.location.origin)
    url.searchParams.set("q", query)

    fetch(url, {
      headers: { Accept: "text/html" },
      signal: this.abortController.signal
    })
      .then((response) => {
        if (!response.ok) throw new Error("preview request failed")
        return response.text()
      })
      .then((html) => {
        this.previewTarget.innerHTML = html
        this.previewTarget.classList.remove("hidden")
      })
      .catch((error) => {
        if (error.name !== "AbortError") this.hide()
      })
  }

  hide() {
    this.previewTarget.classList.add("hidden")
    this.previewTarget.innerHTML = ""
  }
}
