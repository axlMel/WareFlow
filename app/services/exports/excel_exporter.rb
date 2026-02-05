module Exports
  class ExcelExporter < BaseExporter
    def export
      package = Axlsx::Package.new
      workbook = package.workbook

      workbook.add_worksheet(name: sheet_name) do |sheet|
        sheet.add_row headers
        records.each do |record|
          sheet.add_row row(record)
        end
      end

      package
    end

    private

    def sheet_name
      "Data"
    end

    def headers
      raise NotImplementedError
    end

    def row(record)
      raise NotImplementedError
    end
  end
end
