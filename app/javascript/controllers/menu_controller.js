import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "pinIcon", "pinPinnedIcon", "pinUnpinnedIcon", "submenu"]

  connect() {
    this.pinned = localStorage.getItem("sidebarPinned") === "true"

    // Asegurarse de aplicar el estado guardado
    if (this.pinned) {
      this.expand(true)
    } else {
      this.collapse()
    }

    this._updatePinIcon()

    // Restaurar submenús colapsados al cargar
    this.submenuTargets.forEach(submenu => {
      submenu.classList.add("collapsed")
      submenu.style.maxHeight = "0px"
    })
  }

  expand(force = false) {
    if (this.pinned && !force) return

    clearTimeout(this._collapseTimeout)
    clearTimeout(this._expandTimeout)

    this.sidebarTarget.classList.remove("w-20")
    this.sidebarTarget.classList.add("w-60")

    this._expandTimeout = setTimeout(() => {
      this.sidebarTarget.classList.add("sidebar-expanded")
    }, 300)
  }

  collapse() {
    if (this.pinned) return

    clearTimeout(this._expandTimeout)
    clearTimeout(this._collapseTimeout)

    this.sidebarTarget.classList.remove("sidebar-expanded")

    this._collapseTimeout = setTimeout(() => {
      this.sidebarTarget.classList.remove("w-60")
      this.sidebarTarget.classList.add("w-20")
    }, 250)

    this.submenuTargets.forEach(submenu => {
      submenu.style.maxHeight = "0px"
      submenu.classList.add("collapsed")
    })
  }

  togglePin() {
    this.pinned = !this.pinned
    localStorage.setItem("sidebarPinned", this.pinned)

    if (this.pinned) {
      this.expand(true)
    } else {
      this.collapse()
    }

    this._updatePinIcon()
  }

  _updatePinIcon() {
    if (!this.hasPinPinnedIconTarget || !this.hasPinUnpinnedIconTarget) return

    this.pinPinnedIconTarget.classList.toggle("hidden", !this.pinned)
    this.pinUnpinnedIconTarget.classList.toggle("hidden", this.pinned)
  }

  toggleSubmenu(event) {
    const button = event.currentTarget
    const submenu = button.nextElementSibling

    if (!submenu) return

    if (submenu.classList.contains("collapsed")) {
      submenu.classList.remove("collapsed")
      submenu.style.maxHeight = submenu.scrollHeight + "px"
    } else {
      submenu.style.maxHeight = submenu.scrollHeight + "px"
      submenu.offsetHeight
      submenu.style.maxHeight = "0px"
      submenu.classList.add("collapsed")
    }
  }
}
