import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML
    const timestamp = new Date().getTime()
    const newContent = content.replace(/NEW_RECORD/g, timestamp)
    this.containerTarget.insertAdjacentHTML("beforeend", newContent)
  }
  
  remove(event) {
    event.preventDefault()
    const item = event.target.closest(".assignment-fields")
    const destroyInput = item.querySelector("input[name*='_destroy']")
    
    if (destroyInput) {
      destroyInput.value = 1
      item.style.display = "none"
    } else {
      item.remove()
    }
  }
}
