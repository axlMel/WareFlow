import { Application } from "@hotwired/stimulus"
import { Alert } from "tailwindcss-stimulus-components"

// Inicia Stimulus
const application = Application.start()

// Configura Stimulus
application.debug = false
window.Stimulus = application

// Registra manualmente controladores externos
application.register("alert", Alert)

export { application }