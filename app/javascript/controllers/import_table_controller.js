import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tbody", "template", "row", "bulkBadge"]

  connect() {
    this.index = this.tbodyTarget.children.length
    this.reindexRows()
    // NO mostramos badge al cargar
  }

  addRow() {
    let content = this.templateTarget.innerHTML

    content = content.replace(/INDEX/g, this.index)
    content = content.replace(/INDEX_NUMBER/g, this.index + 1)

    this.tbodyTarget.insertAdjacentHTML("beforeend", content)

    this.index++
    this.reindexRows()
  }

  removeRow(event) {
    event.target.closest("tr").remove()
    this.reindexRows()
  }

  applyBulk(event) {
    const field = event.target.dataset.field
    const value = event.target.value

    if (!value) return
    if (!this.hasRowTarget) return

    let modifiedCount = 0

    this.rowTargets.forEach(row => {
      const input = row.querySelector(`[name*="[${field}]"]`)
      if (!input) return

      if (!input.value) {
        input.value = value
        modifiedCount++
      }
    })

    this.updateBulkBadge(modifiedCount)
  }

  updateBulkBadge(count) {
    if (!this.hasBulkBadgeTarget) return

    if (count > 0) {
      this.bulkBadgeTarget.textContent = `Aplicado a ${count} fila${count > 1 ? "s" : ""}`
      this.bulkBadgeTarget.classList.remove("hidden")
    } else {
      this.bulkBadgeTarget.classList.add("hidden")
    }
  }

  reindexRows() {
    this.rowTargets.forEach((row, index) => {
      const firstCell = row.querySelector("td")
      if (firstCell) {
        firstCell.textContent = index + 1
      }
    })
  }
}
