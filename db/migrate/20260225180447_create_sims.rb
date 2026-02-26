class CreateSims < ActiveRecord::Migration[8.0]
  def change
    create_table :sims do |t|
      t.string  :iccid, null: false
      t.string :provider
      t.string :apn
      t.string :phone_number
      t.integer :status, null: false, default: 0
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end
    add_index :sims, :iccid, unique: true
  end
end
