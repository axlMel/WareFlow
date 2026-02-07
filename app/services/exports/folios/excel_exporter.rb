module Exports
  module Folios
    class ExcelExporter < Exports::ExcelExporter
      private

      def sheet_name
        "Folios"
      end

      def build_document(sheet)
        add_title(sheet, "Listado de Folios")

        add_metadata(
          sheet,
          base_metadata + filter_metadata
        )

        add_table(sheet)
        sheet.column_widths 12, 30, 18, 40, 15, 20, 18
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
          I18n.t("activerecord.attributes.folio.statuses.#{folio.status}"),
          folio.user&.username,
          folio.created_at.strftime("%d/%m/%Y")
        ]
      end
    end
  end
end

