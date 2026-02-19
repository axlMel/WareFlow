module Imports
  module Warranties
    class Persister
      attr_reader :errors

      def initialize(rows)
        @rows = rows
        @errors = {}
      end
      
      def persist
        ActiveRecord::Base.transaction do
          @rows.each_with_index do |row, index|
            warranty = Warranty.new(
              client: row["client"],
              commit: row["commit"],
              user_id: row["user_id"],
              product_id: row["product_id"],
              state: :pending
            )

            unless warranty.save
              @errors[index] = warranty.errors
              raise ActiveRecord::Rollback
            end
          end
        end

        @errors.empty?
      end
    end
  end
end
