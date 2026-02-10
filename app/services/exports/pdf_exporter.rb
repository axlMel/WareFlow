module Exports
  class PdfExporter < BaseExporter
    def export
      Prawn::Document.new do |pdf|
        build_header(pdf)
        build_context(pdf)
        build_table(pdf)
        build_footer(pdf)
      end
    end

    private

    def build_header(pdf)
      raise NotImplementedError
    end

    def build_context(pdf)
      # opcional
    end

    def build_table(pdf)
      pdf.move_down 10
      pdf.table(table_data, header: true, column_widths: [120, 60, 200, 50, 50, 60], cell_style: { size: 9, padding: [4, 6, 4, 6], inline_format: true}) do
        row(0).font_style = :bold
        row(0).background_color = "EEEEEE"

        columns(2).style overflow: :shrink_to_fit
      end
    end

    def build_footer(pdf)
      pdf.number_pages "Página <page> de <total>", at: [pdf.bounds.right - 150, 0]
    end

    def table_data
      [headers] + records.map { |r| row(r) }
    end

    def headers
      raise NotImplementedError
    end

    def row(record)
      raise NotImplementedError
    end
  end
end
