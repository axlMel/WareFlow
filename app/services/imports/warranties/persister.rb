module Imports
  module Warranties
    class Persister
      def initialize(rows)
        @rows = rows
      end

      def persist!
        ActiveRecord::Base.transaction do
          @rows.each do |row|
            Warranty.create!(
              client: row["client"],
              commit: row["commit"],
              user_id: row["user_id"],
              product_id: row["product_id"],
              state: row["state"]
            )
          end
        end
      end
    end
  end
end
