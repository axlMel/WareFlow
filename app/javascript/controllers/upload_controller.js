import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input","preview","filename"]

  preview(event) {
    const file = event.target.files[0]
    if (!file) return

    this.filenameTarget.textContent = file.name
    this.previewTarget.hidden = false
  }

  remove() {
    this.inputTarget.value = ""
    this.previewTarget.hidden = true
  }

  dragOver(event) {
    event.preventDefault()
  }

  drop(event) {
    event.preventDefault()

    const file = event.dataTransfer.files[0]
    if (!file) return

    this.inputTarget.files = event.dataTransfer.files
    this.preview({ target: this.inputTarget })
  }

}
