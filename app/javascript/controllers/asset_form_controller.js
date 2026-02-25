import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "currency", "assetType"]

  handleTickerChange(event) {
    const option = this.findSelectedOption(event?.target)
    this.applyOption(option)
  }

  applyTicker(event) {
    const option = event.detail || {}
    this.applyOption(option)
  }

  applyOption(option) {
    if (!option) return

    if (this.hasNameTarget && option.name) this.nameTarget.value = option.name

    if (this.hasCurrencyTarget && option.currency) this.setSelectValue(this.currencyTarget, option.currency.toUpperCase())

    const assetType = option.asset_type || this.inferAssetType(option.ticker || option.value || "")
    if (this.hasAssetTypeTarget && assetType) this.setSelectValue(this.assetTypeTarget, assetType)
  }

  setSelectValue(selectElement, value) {
    const normalized = value.toString()
    if (!normalized) return

    if (selectElement.tomselect) {
      const control = selectElement.tomselect
      if (!control.options[normalized]) {
        control.addOption({ value: normalized, text: normalized })
      }
      control.setValue(normalized, true)
      return
    }

    selectElement.value = normalized
    selectElement.dispatchEvent(new Event("change", { bubbles: true }))
  }

  findSelectedOption(selectElement) {
    if (!selectElement) return null

    if (selectElement.tomselect) {
      const control = selectElement.tomselect
      const selectedValue = control.getValue()
      if (!selectedValue) return null
      return control.options[selectedValue] || null
    }

    const selected = selectElement.selectedOptions?.[0]
    if (!selected) return null
    return {
      value: selected.value,
      text: selected.textContent
    }
  }

  inferAssetType(rawTicker) {
    const ticker = rawTicker.toString().trim().toUpperCase()
    if (!ticker) return null
    if (ticker.endsWith("11")) return "fii"
    return "stock"
  }
}
