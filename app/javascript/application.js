import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import TomSelectController from "./controllers/tom_select_controller"
import ModalController from "./controllers/modal_controller"
import ChartController from "./controllers/chart_controller"
import CurrencyController from "./controllers/currency_controller"
import DropdownController from "./controllers/dropdown_controller"
import PrivacyController from "./controllers/privacy_controller"
import MobileMenuController from "./controllers/mobile_menu_controller"
import ThemeController from "./controllers/theme_controller"
import BuyOrderController from "./controllers/buy_order_controller"
import ToastController from "./controllers/toast_controller"
import GlobalSearchController from "./controllers/global_search_controller"
import FlatpickrDatepicker from "./flatpickr_datepicker"

const application = Application.start()

// Make Stimulus available globally (useful for debugging)
window.Stimulus = application

application.register("tom-select", TomSelectController)
application.register("modal", ModalController)
application.register("chart", ChartController)
application.register("currency", CurrencyController)
application.register("dropdown", DropdownController)
application.register("privacy", PrivacyController)
application.register("mobile-menu", MobileMenuController)
application.register("theme", ThemeController)
application.register("buy-order", BuyOrderController)
application.register("toast", ToastController)
application.register("global-search", GlobalSearchController)

const withController = (element, controllerName) => {
  const current = (element.getAttribute("data-controller") || "").trim()
  const controllers = current ? current.split(/\s+/) : []
  if (controllers.includes(controllerName)) return
  controllers.push(controllerName)
  element.setAttribute("data-controller", controllers.join(" "))
}

const enhanceFormControls = (root = document) => {
  if (root instanceof Element && root.matches("select:not([data-no-tom-select])")) {
    withController(root, "tom-select")
  }

  root.querySelectorAll("select:not([data-no-tom-select])").forEach((select) => {
    withController(select, "tom-select")
  })
}

const flatpickrDatepicker = new FlatpickrDatepicker({
  selectors: ["#flatpickr-date", "#flatpickr-date-filter", "#flatpickr-date-buy"],
  config: {
    monthSelectorType: "static",
    dateFormat: "Y-m-d",
    altInput: true,
    altFormat: "d/m/Y",
    locale: (window.flatpickr && window.flatpickr.l10ns && window.flatpickr.l10ns.pt) || "pt"
  }
})

const flatpickrMonthPicker = new FlatpickrDatepicker({
  selectors: ["#flatpickr-budget-month"],
  config: () => {
    const monthSelectPlugin = window.monthSelectPlugin
    const plugins = monthSelectPlugin ? [
      new monthSelectPlugin({
        shorthand: false,
        dateFormat: "Y-m-d",
        altFormat: "F/Y"
      })
    ] : []

    return {
      monthSelectorType: "static",
      dateFormat: "Y-m-d",
      altInput: true,
      altFormat: "F/Y",
      locale: (window.flatpickr && window.flatpickr.l10ns && window.flatpickr.l10ns.pt) || "pt",
      plugins,
      onChange: (_selectedDates, _dateStr, instance) => {
        instance.input.closest("form")?.requestSubmit()
      }
    }
  }
})

window.addEventListener("load", () => {
  enhanceFormControls()
  flatpickrDatepicker.init()
  flatpickrMonthPicker.init()
})

document.addEventListener("turbo:load", () => {
  enhanceFormControls()
  flatpickrDatepicker.init()
  flatpickrMonthPicker.init()
})
document.addEventListener("turbo:frame-load", (event) => {
  enhanceFormControls(event.target)
  flatpickrDatepicker.init(event.target)
  flatpickrMonthPicker.init(event.target)
})

const observer = new MutationObserver((mutations) => {
  mutations.forEach((mutation) => {
    mutation.addedNodes.forEach((node) => {
      if (node.nodeType !== Node.ELEMENT_NODE) return
      enhanceFormControls(node)
      flatpickrDatepicker.init(node)
      flatpickrMonthPicker.init(node)
    })
  })
})

observer.observe(document.documentElement, { childList: true, subtree: true })

export { application }
