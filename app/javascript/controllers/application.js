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
document.addEventListener("DOMContentLoaded", () => {

  document.querySelectorAll(".device-row").forEach(row => {
    row.addEventListener("click", () => {

      document.querySelectorAll(".device-row")
        .forEach(r => r.classList.remove("bg-blue-200"))

      row.classList.add("bg-blue-200")

      document.getElementById("selected_device")
        .value = row.dataset.deviceId

      document.getElementById("selected_device_label")
        .innerText = "Device: " + row.dataset.deviceImei
    })
  })

  document.querySelectorAll(".sim-row").forEach(row => {
    row.addEventListener("click", () => {

      document.querySelectorAll(".sim-row")
        .forEach(r => r.classList.remove("bg-green-200"))

      row.classList.add("bg-green-200")

      document.getElementById("selected_sim")
        .value = row.dataset.simId

      document.getElementById("selected_sim_label")
        .innerText = "SIM: " + row.dataset.simIccid
    })
  })

})