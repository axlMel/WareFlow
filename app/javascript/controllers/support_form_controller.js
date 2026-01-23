import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "client", "folio_id", "folioId", "user", "service", "userId", "formFields", "productsContainer", "card", "selectProduct", "commandOutput", "zoomModal", "zoomImageLarge", "zoomableImage", "replacement"]

  connect() {
    this.manualMode = false
    this.timeout = null
    this.lastFetchedFolioId = null
  }


  searchFolio(event) {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      const value = this.searchTarget.value.trim()
      const folioIdMatch = value.match(/^#(\d+)/)
      if (!folioIdMatch) return

      const folioId = folioIdMatch[1]

      // 🔓 Desactivar manual mode si el usuario vuelve a elegir folio
      this.manualMode = false
      this.searchTarget.disabled = false

      if (folioId === this.lastFetchedFolioId) return
      this.lastFetchedFolioId = folioId

      fetch(`/folios/api/${folioId}/data`, {
        headers: { "Accept": "application/json" }
      })
        .then(res => res.json())
        .then(data => this.fillForm(data))
        .catch(err => console.error("Error al obtener datos del folio:", err))
    }, 300)
  }

  fillForm(data) {
    this.manualMode = false
    this.searchTarget.disabled = false

    // Activar todos los campos (incluyendo folio) y remover sombra
    this.formFieldsTarget.querySelectorAll("input, textarea").forEach(el => {
      el.removeAttribute("readonly")
      el.classList.remove("bg-gray-100")
    })

    // Asignar valores al formulario
    this.clientTarget.value = data.client || ""
    // Yo digo que es folioIdTarget 
    this.folioIdTarget.value = `${data.folio_id}` || ""
    this.userTarget.value = data.user || ""
    this.serviceTarget.value = data.service || ""
    this.userIdTarget.value = data.user_id || ""

    const statusInput = this.formFieldsTarget.querySelector("input[name='status']")
    if (statusInput) {
      statusInput.value = data.status || ""
    }

    // 🧩 Renderizar productos asignados
    this.loadProducts(data.folio_id)
  }

  disableFolioMode() {
    this.manualMode = true
    this.searchTarget.disabled = false
    this.searchTarget.value = ""
    this.folioTarget.value = "000000"

    this.formFieldsTarget.querySelectorAll("input, textarea").forEach(el => {
      if (el.dataset.supportFormTarget !== "folio") {
        el.removeAttribute("readonly")
        el.classList.remove("bg-gray-100")
      } else {
        el.setAttribute("readonly", true)
        el.classList.add("bg-gray-100")
      }
    })
  }

  enableFormFields() {
    this.manualMode = false
    this.formFieldsTarget.querySelectorAll("input, textarea").forEach(el => {
      el.removeAttribute("readonly")
      el.classList.remove("bg-gray-100")
    })
  }

  loadProducts(folioId) {
    fetch(`/folios/api/${folioId}/products`, {
      headers: { "Accept": "text/html" }
    })
      .then(res => res.text())
      .then(html => {
        this.productsContainerTarget.innerHTML = html;
        this.disconnect();
        this.connect();

      })
      .catch(err => console.error("Error al cargar productos:", err));
  }


  toggleReplacement(event) {
    const assignmentId = event.target.name.match(/\d+/)[0];
    const isDefective = event.target.value === "defective";

    const card = event.target.closest("[data-product-card-target='card']");
    const index = card?.dataset.index;

    const replacementDivs = this.element.querySelectorAll(`[data-replacement-for="${assignmentId}"]`);

    replacementDivs.forEach(div => {
      if (div.dataset.index === index) {
        div.classList.toggle("hidden", !isDefective);
      } else {
        div.classList.add("hidden"); // oculta otras
      }
    });
  }


  submitReplacement(event) {
    const index = event.target.dataset.index;
    const selectWrapper = this.replacementTargets.find(
      el => el.dataset.replacementFor === assignmentId && el.dataset.index === index
    );

    const select = selectWrapper.querySelector("select");
    const replacementProductId = select.value;

    const quantityInput = selectWrapper.querySelector("input[type='number']");
    const quantity = quantityInput ? quantityInput.value : 1;

    if (!replacementProductId) return;

    const commitInput = selectWrapper.querySelector('input[name^="replacement_commit"]');
    const commit = commitInput ? commitInput.value : "";

    

    fetch("/replacements", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this.getToken() },
      body: JSON.stringify({
        replacement_product_id: replacementProductId,
        quantity: quantity,
        commit: commit
      }),
    })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          this.showNotice("Reemplazo guardado correctamente.");

          // ✅ Encontrar el <option> seleccionado
          const selectedOption = select.options[select.selectedIndex];
          const currentStock = parseInt(selectedOption.dataset.stock, 10);
          const newQuantity = currentStock - quantity;

          // ✅ Actualizar visualmente el texto de la opción
          selectedOption.dataset.stock = newQuantity;
          selectedOption.textContent = `${selectedOption.textContent.replace(/Stock: \d+/, `Stock: ${newQuantity}`)}`;


          // ✅ Simular que se marcó como "usado"
          const usedRadio = selectWrapper.closest("div[data-product-card-target='card']")
            .querySelector(`input[type="radio"][value="used"]`);
          if (usedRadio) usedRadio.checked = true;

        } else {
          alert(data.error || "Error al guardar reemplazo");
        }
      });
  }

  getToken() {
    const token = document.querySelector("meta[name='csrf-token']");
    return token ? token.content : "";
  }


  showNotice(message) {
    const notice = document.createElement("div");
    notice.className = "fixed top-4 right-4 bg-green-500 text-white px-4 py-2 rounded shadow-lg z-50";
    notice.textContent = message;
    document.body.appendChild(notice);
    setTimeout(() => notice.remove(), 3000);
  }

  selectProduct(event) {
    const ignoredTags = ["INPUT", "BUTTON", "SELECT", "OPTION", "TEXTAREA"];
    if (ignoredTags.includes(event.target.tagName)) return;
    const selectedCard = event.currentTarget;

    this.productsContainerTarget.querySelectorAll("[data-product-card-target='card']")
      .forEach(el => el.classList.remove("ring-2", "ring-blue-500"));

    selectedCard.classList.add("ring-2", "ring-blue-500");

    const assignmentId = selectedCard.dataset.assignmentId;
    this.updateDiagramAndCommand(assignmentId);
  }

  updateDiagramAndCommand(assignmentId) {
    const productCard = this.element.querySelector(`[data-assignment-id='${assignmentId}']`);
    if (!productCard) return;

    // Usamos un atributo personalizado para guardar el product_id
    const productId = productCard.dataset.productId;
    if (!productId) return;

    console.log("productId a consultar:", productId);

    fetch(`/products/${productId}/installation_guide`, {
      headers: { "Accept": "text/html" }
    })
      .then(res => res.text())
      .then(html => {
        const container = document.querySelector("#installation-guide-container");
        if (container) container.innerHTML = html;
      })
      .catch(err => console.error("Error al cargar guía de instalación:", err));
  }

  copyCommands(event) {
    console.log("🧠 copyCommands fue llamado");

    if (!this.hasCommandOutputTarget) {
      console.warn("⚠️ No se encontró el target `commandOutput`");
      return;
    }

    const labels = Array.from(this.commandOutputTarget.querySelectorAll("span"));
    const codes = Array.from(this.commandOutputTarget.querySelectorAll("code"));

    const commandsText = labels.map((label, index) => {
      const code = codes[index]; // El código relacionado al label
      if (code) {
        // Devolver el texto del label y del código, formateado correctamente
        return `${label.textContent.trim()}\n${code.textContent.trim()}`;
      }
      return ""; // Si no hay un `code` correspondiente, ignorar ese par
    }).join("\n\n");

    const btn = event.currentTarget;

    navigator.clipboard.writeText(commandsText)
      .then(() => {
        btn.textContent = "Copiado!";
        btn.classList.add("bg-green-600");
        setTimeout(() => {
          btn.classList.remove("bg-green-600");
          btn.textContent = "Copiar";
        }, 2000);
      })
      .catch(err => {
        console.error("Error copiando al portapapeles:", err);
      });
  }


  
  zoomImage(event) {
    const src = event.target.src;
    if (!src) return;

    this.zoomImageLargeTarget.src = src;
    this.zoomModalTarget.classList.remove("hidden");
  }


  closeZoom(event) {
    // Solo cerrar si se da clic fuera de la imagen
    if (event.target === this.zoomModalTarget) {
      this.zoomModalTarget.classList.add("hidden")
      this.zoomImageLargeTarget.src = "#"
    }else
    this.zoomModalTarget.classList.add("hidden");
    this.zoomImageLargeTarget.src = ""; // Limpia la imagen para liberar memoria

  }
  stopPropagation(event) {
    event.stopPropagation(); // Para que al hacer click dentro del panel, no se cierre
  }


}