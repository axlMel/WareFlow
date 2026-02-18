module Imports
  module Warranties
    class Persister
      attr_reader :errors

      def initialize(rows)
        @rows = rows
        @errors = {}
      end

      def persist
        success = true

        @rows.each_with_index do |row, index|
          warranty = Warranty.new(
            client: row["client"],
            commit: row["commit"],
            user_id: row["user_id"],
            product_id: row["product_id"],
            state: row["state"]
          )
          unless warranty.save
            success = false
            @errors[index] = warranty.errors
          end
        end
        success
      end
    end
  end
end
