import { Application } from "@hotwired/stimulus"
import TomSelectController from "./tom_select_controller"
import ModalController from "./modal_controller"
import ChartController from "./chart_controller"
import CurrencyController from "./currency_controller"
import DropdownController from "./dropdown_controller"
import PrivacyController from "./privacy_controller"

const application = Application.start()

// Make Stimulus available globally (useful for debugging)
window.Stimulus = application

application.register("tom-select", TomSelectController)
application.register("modal", ModalController)
application.register("chart", ChartController)
application.register("currency", CurrencyController)
application.register("dropdown", DropdownController)
application.register("privacy", PrivacyController)
