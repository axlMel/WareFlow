module Exports
  module Folios
    class ExcelExporter < Exports::ExcelExporter
      private

      def sheet_name
        "Folios"
      end

      def headers
        ["ID",
          "Cliente", 
          "Servicio", 
          "Accesorios",
          "Estado",
          "Usuario",
          "Fecha creacion"]
      end

      def row(folio)
        [folio.id,
          folio.client,
          folio.service,
          folio.accessories,
          folio.status,
          folio.user&.username,
          folio.created_at.strftime("%d/%m/%Y")
        ]
      end
    end
  end
end
