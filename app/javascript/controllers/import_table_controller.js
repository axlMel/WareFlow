import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tbody", "template", "row"]

  connect() {
    this.index = this.tbodyTarget.children.length
  }

  addRow() {
    let content = this.templateTarget.innerHTML.replace(/INDEX/g, this.index)
    this.tbodyTarget.insertAdjacentHTML("beforeend", content)
    this.index++
  }

  removeRow(event) {
    event.target.closest("tr").remove()
  }

  applyBulk(event) {
    const field = event.target.dataset.field
    const value = event.target.value

    if (!value) return
    if (!this.hasRowTarget) return

    this.rowTargets.forEach(row => {
      const input = row.querySelector(`[name*="[${field}]"]`)
      if (!input) return

      if (!input.value){
        input.value = value
      }
    })
  }

  validateRow(row) {
    let valid = true

    const requiredFields = ["client", "user_id", "product_id", "state"]

    requiredFields.forEach(field => {
      const input = row.querySelector(`[name*="[${field}]"]`)
      if (!input || !input.value.trim()) {
        valid = false
      }
    })

    if (!valid) {
      row.classList.add("bg-red-50", "border-red-400")
    } else {
      row.classList.remove("bg-red-50", "border-red-400")
    }

    return valid
  }

  validate(event){
    const row = event.target.closest("tr")
    this.validateRow(row)
  }

  validateAll(){
    this.rowTargets.forEach(row =>{
      this.validateRow(row)
    })
  }
}
