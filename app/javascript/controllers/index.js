import { Application } from "@hotwired/stimulus"
import Select2Controller from "./select2_controller"
import ModalController from "./modal_controller"
import ChartController from "./chart_controller"
import CurrencyController from "./currency_controller"
import DropdownController from "./dropdown_controller"
import PrivacyController from "./privacy_controller"

const application = Application.start()

// Make Stimulus available globally (useful for debugging)
window.Stimulus = application

application.register("select2", Select2Controller)
application.register("modal", ModalController)
application.register("chart", ChartController)
application.register("currency", CurrencyController)
application.register("dropdown", DropdownController)
application.register("privacy", PrivacyController)
