import { Application } from "@hotwired/stimulus"
import Select2Controller from "./select2_controller"

const application = Application.start()

// Make Stimulus available globally (useful for debugging)
window.Stimulus = application

application.register("select2", Select2Controller)
