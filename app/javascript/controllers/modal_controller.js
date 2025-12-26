// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["background", "panel"]

  connect() {
    setTimeout(() => {
      this.panelTarget.classList.remove("scale-95")
      this.panelTarget.classList.add("scale-100")
    }, 10)

    this.element.addEventListener("turbo:submit-end", (event) => {
      if (event.detail.success) {
        this.close()
        Turbo.visit(event.detail.fetchResponse.response.url)
      }
    })
  }

  close() {
    this.element.remove()
  }

  closeOnBackgroundClick(event) {
    if (event.target === this.backgroundTarget) {
      this.close()
    }
  }
}
