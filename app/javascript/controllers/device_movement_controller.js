import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "actionType", "title", "description", "simField", "submit"]

  connect() {
    const hasSim = this.element.dataset.hasSim === "true"
    this.setMode(hasSim ? "replace" : "assign")
  }

  setReplace() {
    this.setMode("replace")
  }

  setAssign() {
    this.setMode("assign")
  }

  setRemove() {
    this.setMode("remove")
  }

  setWarranty() {
    this.setMode("warranty")
  }

  setDamaged() {
    this.setMode("damaged")
  }

  setReturned() {
    this.setMode("returned")
  }

  setMode(mode) {
    this.actionTypeTarget.value = mode

    const config = {
      assign: {
        title: "Asignar SIM",
        description: "Selecciona una SIM disponible y registra el motivo de la asignación.",
        showSim: true,
        submit: "Asignar SIM"
      },
      replace: {
        title: "Reemplazar SIM",
        description: "Selecciona una nueva SIM disponible y registra el motivo del cambio.",
        showSim: true,
        submit: "Reemplazar SIM"
      },
      remove: {
        title: "Quitar SIM",
        description: "Desasocia la SIM actual del dispositivo e indica el motivo.",
        showSim: false,
        submit: "Confirmar baja"
      },
      warranty: {
        title: "Enviar a garantía",
        description: "Marca el equipo en garantía y registra el motivo del movimiento.",
        showSim: false,
        submit: "Enviar a garantía"
      },
      damaged: {
        title: "Marcar como dañado",
        description: "Marca el dispositivo como dañado y registra el motivo.",
        showSim: false,
        submit: "Marcar como dañado"
      },
      returned: {
        title: "Devolver al proveedor",
        description: "Enviar de vuelta al proveedor y marcar devolución, registra el motivo por favor.",
        showSim: false,
        submit: "Marcar como dañado"
      }
    }

    const current = config[mode]
    this.titleTarget.textContent = current.title
    this.descriptionTarget.textContent = current.description
    this.submitTarget.value = current.submit

    if (current.showSim) {
      this.simFieldTarget.classList.remove("hidden")
    } else {
      this.simFieldTarget.classList.add("hidden")
    }
  }
}