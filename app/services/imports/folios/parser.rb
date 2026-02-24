module Imports
  module Folios
    class Parser
      attr_reader :file, :spreadsheet, :header

      def initialize(file)
        @file = file
        @spreadsheet = Roo::Spreadsheet.open(file.path)
        @header = spreadsheet.row(1).map { |h| h.to_s.downcase }
      end

      def parse
        rows = []

        (2..spreadsheet.last_row).each do |i|
          row = Hash[@header.zip(spreadsheet.row(i))]

          rows << {
            client: row["cliente"],
            service: nil,
            accesories: row["accesorio"]
          }
        end

        rows
      end
    end
  end
end
