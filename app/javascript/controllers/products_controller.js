import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productRow"]

  markDefective(event) {
    const productRow = event.currentTarget.closest(".product-row")
    const replacementSelector = productRow.querySelector(".replacement-selector")
    if (event.currentTarget.checked) {
      replacementSelector.classList.remove("hidden")
    } else {
      replacementSelector.classList.add("hidden")
    }
  }

  loadReplacements(event) {
    const assignmentId = event.target.dataset.assignmentId
    const select = event.target.closest(".product-row").querySelector(".replacement-products")

    fetch(`/assignments/${assignmentId}/available_replacements`, {
      headers: { "Accept": "application/json" }
    })
      .then(res => res.json())
      .then(data => {
        select.innerHTML = ""
        data.forEach(product => {
          const option = document.createElement("option")
          option.value = product.id
          option.textContent = `${product.title} - Stock: ${product.stock}`
          select.appendChild(option)
        })
      })
  }
}