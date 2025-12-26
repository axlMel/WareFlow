import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["stock"]

  update(event) {
    const productId = event.target.value

    if (!this.hasStockTarget) return // Evita error si falta el target

    if (!productId) {
      this.stockTarget.textContent = "-"
      return
    }

    fetch(`/${productId}/stock`)
      .then(response => response.json())
      .then(data => {
        this.stockTarget.textContent = data.stock
      })
      .catch(() => {
        this.stockTarget.textContent = "Error"
      })
  }
}
