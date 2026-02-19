module Imports
  module Warranties
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
            commit: row["comentario"],
            user_id: nil,
            product_id: nil,
            state: "pending"
          }
        end

        rows
      end
    end
  end
end
