module Exports
  module Folios
    class PdfExporter < Exports::PdfExporter
      private

      def title
        "Listado de Folios"
      end

      def headers
        ["Cliente", "Servicio", "Accesorios", "Estado", "Usuario", "Fecha"]
      end

      def row(folio)
        [
          folio.client,
          folio.service,
          folio.accessories,
          folio.status,
          folio.user&.username || "—",
          folio.created_at.strftime("%d/%m/%Y")
        ]
      end
    end
  end
end
