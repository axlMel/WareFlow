class CreateDeviceMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :device_movements do |t|
      t.references :device, null: false, foreign_key: true
      t.references :sim, foreign_key: true
      t.integer :movement_type, null: false
      t.integer :from_status
      t.integer :to_status
      t.string :reason, null: false
      t.datetime :performed_at, null: false

      t.timestamps
    end
  end
end