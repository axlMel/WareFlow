module Imports
  class FoliosImporter < BaseImporter
    private

    def process_rows
      each_row do |row|
        Folio.create!(
          client: row["cliente"],
          service: row["servicio"],
          accessories: row["accesorio"]
        )
      end
    end
  end
end
