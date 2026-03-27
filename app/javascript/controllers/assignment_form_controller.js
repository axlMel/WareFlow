import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["type", "productSection", "deviceSection", "simSection", "quantitySection"]

  connect() {
    this.toggle()
  }

  toggleType() {
    this.toggle()
  }

  toggle() {
    const type = this.typeTarget.value

    this.productSectionTarget.classList.toggle("hidden", type !== "product")
    this.deviceSectionTarget.classList.toggle("hidden", type !== "device")
    this.simSectionTarget.classList.toggle("hidden", type !== "sim")
    this.quantitySectionTarget.classList.toggle("hidden", type !== "product")
  }
}