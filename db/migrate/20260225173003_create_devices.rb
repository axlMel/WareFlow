class CreateDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :devices do |t|
      t.string  :imei, null: false
      t.string :brand
      t.string :model
      t.integer :status, null: false, default: 0
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end
    add_index :devices, :imei, unique: true
  end
end
