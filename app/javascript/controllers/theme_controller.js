import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "myfinance-theme"

export default class extends Controller {
  static targets = ["iconSun", "iconMoon", "label", "button"]

  connect() {
    this.applyTheme(this.preferredTheme())
  }

  toggle() {
    const nextTheme = document.documentElement.classList.contains("dark") ? "light" : "dark"
    try {
      localStorage.setItem(STORAGE_KEY, nextTheme)
    } catch (_) {}
    this.applyTheme(nextTheme)
  }

  preferredTheme() {
    let stored = null
    try {
      stored = localStorage.getItem(STORAGE_KEY)
    } catch (_) {}
    if (stored === "light" || stored === "dark") {
      return stored
    }

    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  applyTheme(theme) {
    const isDark = theme === "dark"
    document.documentElement.classList.toggle("dark", isDark)
    if (document.body) {
      document.body.classList.toggle("dark", isDark)
    }

    if (this.hasIconSunTarget) {
      this.iconSunTarget.classList.toggle("hidden", !isDark)
    }

    if (this.hasIconMoonTarget) {
      this.iconMoonTarget.classList.toggle("hidden", isDark)
    }

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = isDark ? "Modo escuro" : "Modo claro"
    }

    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-pressed", isDark ? "true" : "false")
    }

    window.dispatchEvent(new CustomEvent("theme:change", { detail: { theme } }))
  }
}
