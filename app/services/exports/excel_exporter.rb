module Exports
  class ExcelExporter < BaseExporter
    def export
      package = Axlsx::Package.new
      workbook = package.workbook

      @styles = build_styles(workbook)

      workbook.add_worksheet(name: sheet_name) do |sheet|
        build_document(sheet)
      end

      package
    end

    private

    def build_document(sheet)
      raise NotImplementedError
    end

    def build_styles(workbook)
      {
        title: workbook.styles.add_style(
          b: true,
          sz: 16,
          bg_color: "51bce4",
          fg_color: "3c3c3c",
          alignment: { horizontal: :center }
        ),

        section: workbook.styles.add_style(
          b: true
        ),

        header: workbook.styles.add_style(
          b: true,
          bg_color: "51bce4",
          border: { style: :thin, color: "CCCCCC" }
        ),

        meta: workbook.styles.add_style(
          b: true,
          italic: true,
          fg_color: "3c3c3c"
        )
      }
    end

    def add_title(sheet, text)
      sheet.add_row [text], style: @styles[:title]
      sheet.merge_cells("A1:G1")
      sheet.add_row []
    end

    def add_metadata(sheet, rows)
      rows.each do |label, value|
        sheet.add_row ["#{label}: #{value}"], style: @styles[:meta]
      end
      sheet.add_row []
    end

    def add_filters(sheet, filters)
      return if filters.blank?

      sheet.add_row ["Filtros aplicados"], style: @styles[:section]
      filters.each do |key, value|
        sheet.add_row [key, value]
      end
      sheet.add_row []
    end

    def add_table(sheet)
      header_row_index = sheet.rows.size + 1
      sheet.add_row headers, style: @styles[:header]

      records.each do |record|
        sheet.add_row row(record)
      end

      return if records.empty?

      last_column = ('A'.ord + headers.size - 1).chr
      sheet.auto_filter = "A#{header_row_index}:#{last_column}#{sheet.rows.size}"

      sheet.sheet_view.pane do |pane|
        pane.top_left_cell = "A#{header_row_index + 1}"
        pane.state = :frozen
        pane.y_split = 1
       # pane.y_split = header_row_index
        pane.active_pane = :bottom_left
      end
    end

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
