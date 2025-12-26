class AddFieldsToFolios < ActiveRecord::Migration[8.0]
  def change
    add_column :folios, :status, :string
    add_column :folios, :service, :string
    add_column :folios, :accessories, :string
  end
end
