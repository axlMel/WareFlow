module Exports
  class PdfExporter < BaseExporter
    def export
      Prawn::Document.new do |pdf|
        pdf.text title, size: 18, style: :bold
        pdf.move_down 10
        pdf.table table_data
      end
    end

    private

    def title
      raise NotImplementedError
    end

    def headers
      raise NotImplementedError
    end

    def row(record)
      raise NotImplementedError
    end

    def table_data
      [headers] + records.map { |r| row(r) }
    end
  end
end
