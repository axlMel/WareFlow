module Imports
  module Folios
    class Persister
      attr_reader :errors

      def initialize(rows)
        @rows = rows
        @errors = {}
      end
      
      def persist
        ActiveRecord::Base.transaction do
          @rows.each_with_index do |row, index|
            folio = Folio.new(
              client: row["client"],
              service: row["service"],
              accesories: row["accesories"],
              status: :pending
            )

            unless folio.save
              @errors[index] = folio.errors
              raise ActiveRecord::Rollback
            end
          end
        end

        @errors.empty?
      end
    end
  end
end
