import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["type", "productSection", "deviceSection", "simSection", "quantitySection"]

  changeType() {
    const type = this.typeTarget.value

    this.hideAll()

    if (type === "product") {
      this.productSectionTarget.classList.remove("hidden")
      this.quantitySectionTarget.classList.remove("hidden")
      this.clearDeviceSim()
    }

    if (type === "device") {
      this.deviceSectionTarget.classList.remove("hidden")
      this.clearProduct()
      this.clearSim()
      this.clearQuantity()
    }

    if (type === "sim") {
      this.simSectionTarget.classList.remove("hidden")
      this.clearProduct()
      this.clearDevice()
      this.clearQuantity()
    }
  }

  hideAll() {
    this.productSectionTarget.classList.add("hidden")
    this.deviceSectionTarget.classList.add("hidden")
    this.simSectionTarget.classList.add("hidden")
    this.quantitySectionTarget.classList.add("hidden")
  }

  clearProduct() {
    const el = this.productSectionTarget.querySelector("select")
    if (el) el.value = ""
  }

  clearDevice() {
    const el = this.deviceSectionTarget.querySelector("select")
    if (el) el.value = ""
  }

  clearSim() {
    const el = this.simSectionTarget.querySelector("select")
    if (el) el.value = ""
  }

  clearDeviceSim() {
    this.clearDevice()
    this.clearSim()
  }

  clearQuantity() {
    const el = this.quantitySectionTarget.querySelector("input")
    if (el) el.value = ""
  }
}