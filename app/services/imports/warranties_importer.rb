module Imprts
	class WarrantiesImporter < BaseImporter
    private

    def process_rows
      each_row do |row|
        Warranty.create!(
          client: row["cliente"],
          commit: row["comentario"]
          )     
      end
    end
  end
end