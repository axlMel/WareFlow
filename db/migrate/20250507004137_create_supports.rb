class CreateSupports < ActiveRecord::Migration[8.0]
  def change
    create_table :supports do |t|
      t.bigint :assignment_id
      t.string :service
      t.string :client
      t.bigint :product_id
      t.integer :folio
      t.bigint :user_id
      t.string :type
      t.string :plate
      t.string :eco
      t.text :commit

      t.timestamps
    end
  end
end
