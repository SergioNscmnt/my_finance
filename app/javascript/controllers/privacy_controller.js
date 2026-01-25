import { Controller } from "@hotwired/stimulus"

// Toggle visibility of monetary values by adding/removing a blur class
export default class extends Controller {
  static targets = ["value", "iconShow", "iconHide", "label", "trigger"]

  connect() {
    this.hiddenClasses = ["blur-sm", "select-none"]
    this.hidden = this.hasSavedState() ? this.loadState() : false
    this.apply()
  }

  toggle() {
    this.hidden = !this.hidden
    this.saveState()
    this.apply()
  }

  apply() {
    this.valueTargets.forEach((el) => {
      this.hiddenClasses.forEach((cls) => el.classList.toggle(cls, this.hidden))
    })
    if (this.hasIconShowTarget) this.iconShowTarget.classList.toggle("hidden", this.hidden)
    if (this.hasIconHideTarget) this.iconHideTarget.classList.toggle("hidden", !this.hidden)
    if (this.hasLabelTarget) this.labelTarget.textContent = this.hidden ? "Mostrar valores" : "Ocultar valores"
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute("aria-pressed", this.hidden ? "true" : "false")
  }

  saveState() {
    try {
      window.localStorage.setItem("privacy:hidden", this.hidden ? "1" : "0")
    } catch (_) {}
  }

  loadState() {
    try {
      return window.localStorage.getItem("privacy:hidden") === "1"
    } catch (_) {
      return false
    }
  }

  hasSavedState() {
    try {
      return window.localStorage.getItem("privacy:hidden") !== null
    } catch (_) {
      return false
    }
  }
}
