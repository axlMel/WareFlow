module Exports
	module Warranties
		class PdfExporter < Exports::PdfExporter
			private
			def build_header(pdf)
				pdf.text "Listado de Garantías", size: 18, style: :bold
				pdf.move_down 5
				pdf.text "Reporte operativo", size: 10
				pdf.stroke_horizontal_rule
			end
			def build_context(pdf)
				pdf.move_down 10
				pdf.text "Documento generado el #{Time.current.strftime('%d/%m/%y %H:%M')}"
				pdf.text "Extraido por #{@params[:exported_by] || 'Admin'}"

				return if @params[:filters].blank?
				pdf.move_down 5
				pdf.text "Filtros aplicados:", style: :bold
				@params[:filters].reject { |_k, v| v.blank? }.each do |key, value|
					label = I18n.t("exports.filters.#{key}", default: key.to_s.humanize)
					result = I18n.t("exports.values.#{value}", default: value.to_s.humanize)
					pdf.text "- #{label}: #{result}"
				end
			end

			def column_widths
			  [70, 80, 80, 50, 150, 50, 60]
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