import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "messages", "submit", "status"]
  static values = { url: String }

  submit(event) {
    event.preventDefault()
    const message = this.inputTarget.value.trim()
    if (!message) return

    this.appendMessage(message, "user")
    this.inputTarget.value = ""
    this.setLoading(true)

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken()
      },
      credentials: "same-origin",
      body: JSON.stringify({ message })
    })
      .then(async (response) => {
        const contentType = response.headers.get("content-type") || ""
        if (!contentType.includes("application/json")) {
          const text = await response.text()
          throw new Error("Resposta inesperada do servidor. Verifique login/CSRF.")
        }
        const data = await response.json()
        if (!response.ok) throw new Error(data.error || "Erro desconhecido")
        return data
      })
      .then((data) => {
        this.appendMessage(data.reply, "assistant")
      })
      .catch((error) => {
        this.appendMessage(error.message, "error")
      })
      .finally(() => {
        this.setLoading(false)
      })
  }

  appendMessage(text, role) {
    const row = document.createElement("div")
    row.className = role === "user" ? "flex justify-end" : "flex justify-start"

    const bubble = document.createElement("div")
    const base = "max-w-[85%] rounded-2xl px-4 py-2 text-sm leading-relaxed"
    if (role === "user") {
      bubble.className = `${base} bg-emerald-600 text-white`
    } else if (role === "error") {
      bubble.className = `${base} bg-rose-100 text-rose-800`
    } else {
      bubble.className = `${base} bg-slate-100 text-slate-900`
    }
    bubble.textContent = text

    row.appendChild(bubble)
    this.messagesTarget.appendChild(row)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  setLoading(loading) {
    if (loading) {
      this.submitTarget.disabled = true
      this.submitTarget.classList.add("opacity-60", "cursor-not-allowed")
      this.statusTarget.textContent = "Consultora pensando..."
    } else {
      this.submitTarget.disabled = false
      this.submitTarget.classList.remove("opacity-60", "cursor-not-allowed")
      this.statusTarget.textContent = ""
    }
  }

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.getAttribute("content") || ""
  }
}
