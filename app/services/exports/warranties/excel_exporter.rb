module Exports
	module Warranties
		class ExcelExporter < Exports::ExcelExporter
      private

      def sheet_name
        "Garantías"
      end
      def build_document(sheet)
        add_title(sheet, "Listado de Garantías")
        add_metadata(sheet, base_metadata + filter_metadata)
        add_table(sheet)
        sheet.column_widths 12, 30, 30, 12, 40, 12, 12
      end
      def headers
        ["ID", "Cliente", "Producto", "Usuario", "Comentario", "Fecha", "Estado"]
      end

      def row(warranty)
        [warranty.id, warranty.client, warranty.product&.title, warranty.user&.username, warranty.commit, warranty.created_at.strftime("%d/%m/%y"), I18n.t("activerecord.attributes.warranty.states.#{warranty.state}")]
      end
		end
	end
end