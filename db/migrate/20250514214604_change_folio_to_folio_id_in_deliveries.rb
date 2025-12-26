class ChangeFolioToFolioIdInDeliveries < ActiveRecord::Migration[8.0]
  def change
    rename_column :deliveries, :folio, :folio_id
    add_index :deliveries, :folio_id
    add_foreign_key :deliveries, :folios
  end
end
