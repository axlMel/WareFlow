import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [
    "deviceInput",
    "simInput",
    "pairsContainer",
    "activateButton"
  ]

  connect() {
    this.devices = []
    this.sims = []
  }

  toggleDevice(event) {

    const row = event.currentTarget
    const id = row.dataset.deviceId
    const imei = row.dataset.deviceImei

    const existing = this.devices.find(d => d.id === id)

    if (existing) {

      this.devices = this.devices.filter(d => d.id !== id)
      row.classList.remove("bg-blue-200")

    } else {

      this.devices.push({ id, imei })
      row.classList.add("bg-blue-200")

    }

    this.updateIndexes()
    this.renderPairs()
  }

  toggleSim(event) {

    const row = event.currentTarget
    const id = row.dataset.simId
    const iccid = row.dataset.simIccid

    const existing = this.sims.find(s => s.id === id)

    if (existing) {

      this.sims = this.sims.filter(s => s.id !== id)
      row.classList.remove("bg-green-200")

    } else {

      this.sims.push({ id, iccid })
      row.classList.add("bg-green-200")

    }

    this.updateIndexes()
    this.renderPairs()
  }

  updateIndexes() {

    document.querySelectorAll(".device-row .index-cell")
      .forEach(cell => cell.innerHTML = "")

    document.querySelectorAll(".sim-row .index-cell")
      .forEach(cell => cell.innerHTML = "")

    this.devices.forEach((device, index) => {

      const row = document.querySelector(`[data-device-id="${device.id}"]`)
      const cell = row.querySelector(".index-cell")

      cell.innerHTML = `
        <span class="bg-blue-500 text-white text-xs px-2 py-1 rounded">
          ${index + 1}
        </span>
      `
    })

    this.sims.forEach((sim, index) => {

      const row = document.querySelector(`[data-sim-id="${sim.id}"]`)
      const cell = row.querySelector(".index-cell")

      cell.innerHTML = `
        <span class="bg-green-500 text-white text-xs px-2 py-1 rounded">
          ${index + 1}
        </span>
      `
    })

  }

  renderPairs() {

    this.pairsContainerTarget.innerHTML = ""

    const max = Math.max(this.devices.length, this.sims.length)

    for (let i = 0; i < max; i++) {

      const device = this.devices[i]
      const sim = this.sims[i]

      const row = document.createElement("div")

      row.className = "flex justify-between border-b py-1 text-sm"

      row.innerHTML = `
        <span>${i + 1}. ${device ? device.imei : "—"}</span>
        <span>→</span>
        <span>${sim ? sim.iccid : "—"}</span>
      `

      this.pairsContainerTarget.appendChild(row)
    }

    const pairs = Math.min(this.devices.length, this.sims.length)

    this.deviceInputTarget.value =
      this.devices.slice(0, pairs).map(d => d.id).join(",")

    this.simInputTarget.value =
      this.sims.slice(0, pairs).map(s => s.id).join(",")

    this.activateButtonTarget.disabled = pairs === 0

  }

}