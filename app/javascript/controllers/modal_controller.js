// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["background", "panel"]

  connect() {
    setTimeout(() => {
      this.panelTarget.classList.remove("scale-95")
      this.panelTarget.classList.add("scale-100")
    }, 10)
  }

  close() {
    this.element.parentElement.removeAttribute("src")
    history.replaceState({}, "", location.pathname)
    this.element.remove()
  }

  closeOnBackgroundClick(event) {
    if (event.target === this.backgroundTarget) {
      this.close()
    }
  }
}
