import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  updateClient(event) {
    const selectedOption = event.target.selectedOptions[0]
    const label = selectedOption.textContent

    // Intenta extraer el cliente del texto (ej. "#123 - ClienteXYZ")
    const match = label.match(/-\s*(.+)$/)
    if (match) {
      const clientName = match[1].trim()
      const clientInput = document.querySelector("input[name='delivery[client]']")
      if (clientInput) clientInput.value = clientName
    }
  }
}
