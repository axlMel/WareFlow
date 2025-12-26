// controllers/product_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const productId = event.target.dataset.productId
    const used = document.querySelector(`input[name="selected_products[]"][value="${productId}"]`)
    const defective = document.querySelector(`input[name="defective_products[]"][value="${productId}"]`)

    if (event.target === used && used.checked) {
      defective.checked = false
    } else if (event.target === defective && defective.checked) {
      used.checked = false
    }
  }
}