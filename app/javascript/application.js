//= link controllers/buy_order_controller.js
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import TomSelectController from "./controllers/tom_select_controller"
import ModalController from "./controllers/modal_controller"
import ChartController from "./controllers/chart_controller"
import CurrencyController from "./controllers/currency_controller"
import DropdownController from "./controllers/dropdown_controller"
import PrivacyController from "./controllers/privacy_controller"
import MobileMenuController from "./controllers/mobile_menu_controller"
import DatepickerController from "./controllers/datepicker_controller"
import ThemeController from "./controllers/theme_controller"
import BuyOrderController from "./controllers/buy_order_controller"

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
application.register("datepicker", DatepickerController)
application.register("theme", ThemeController)
application.register("buy-order", BuyOrderController)

export { application }
