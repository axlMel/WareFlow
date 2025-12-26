import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["statusInput", "replacement"]

  markDelivered(event) {
    const assignmentId = event.target.dataset.assignmentId
    this._setStatus(assignmentId, "entregado")
    this._activateButton(assignmentId, event.target)
    this._hideReplacement(assignmentId)
  }

  markDefective(event) {
    const assignmentId = event.target.dataset.assignmentId
    this._setStatus(assignmentId, "fallo")
    this._activateButton(assignmentId, event.target)
    this._showReplacement(assignmentId)
  }

  _setStatus(id, value) {
    const input = this.statusInputTargets.find(t => t.dataset.assignmentId === id)
    if (input) input.value = value
  }

  _activateButton(id, activeBtn) {
    const buttons = this.element.querySelectorAll(`[data-assignment-id='${id}'].status-button`)
    buttons.forEach(btn => {
      btn.classList.remove("bg-indigo-600", "text-white", "border-transparent", "shadow")
    })
    activeBtn.classList.add("bg-indigo-600", "text-white", "border-transparent", "shadow")
  }

  _showReplacement(id) {
    const el = this.replacementTargets.find(t => t.dataset.assignmentId === id)
    if (el) {
      el.classList.remove("max-h-0", "opacity-0")
      el.classList.add("max-h-96", "opacity-100")
    }
  }

  _hideReplacement(id) {
    const el = this.replacementTargets.find(t => t.dataset.assignmentId === id)
    if (el) {
      el.classList.remove("max-h-96", "opacity-100")
      el.classList.add("max-h-0", "opacity-0")
    }
  }
}