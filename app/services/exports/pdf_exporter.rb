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
      pdf.table(table_data, header: true)
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
