module Imports
  class BaseImporter
    attr_reader :file, :spreadsheet, :header

    def initialize(file)
      @file = file
      @spreadsheet = ExcelImporter.open(file)
      @header = spreadsheet.row(1).map { |h| h.to_s.downcase }
    end

    def import!
      ActiveRecord::Base.transaction do
        process_rows
      end
    end

    private

    def process_rows
      raise NotImplementedError
    end

    def each_row
      (2..spreadsheet.last_row).each do |i|
        row = Hash[header.zip(spreadsheet.row(i))]
        yield row
      end
    end
  end
end
