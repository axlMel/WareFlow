module Exports
  module Folios
    class PdfExporter < Exports::PdfExporter
      private

      def build_header(pdf)
        pdf.text "Listado de Folios", size: 18, style: :bold
        pdf.move_down 5
        pdf.text "Reporte operativo", size: 10
        pdf.stroke_horizontal_rule
      end

      def build_context(pdf)
        pdf.move_down 10
        pdf.text "Documento generado el #{Time.current.strftime('%d/%m/%Y %H:%M')}"
        pdf.text "Extraído por: #{@params[:exported_by] || 'Admin'}"

        return if @params[:filters].blank?

        pdf.move_down 5
        pdf.text "Filtros aplicados:", style: :bold

        @params[:filters].reject { |_k, v| v.blank? }.each do |key, value|
          label = I18n.t("exports.filters.#{key}", default: key.to_s.humanize)
          pdf.text "- #{label}: #{value}"
        end
      end

      def headers
        ["Cliente", "Servicio", "Accesorios", "Estado", "Usuario", "Fecha"]
      end

      def row(folio)
        [
          folio.client,
          folio.service,
          folio.accessories,
          I18n.t("activerecord.attributes.folio.statuses.#{folio.status}"),
          folio.user&.username || "—",
          folio.created_at.strftime("%d/%m/%Y")
        ]
      end
    end
  end
end
