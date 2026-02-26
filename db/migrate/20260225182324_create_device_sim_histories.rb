class CreateDeviceSimHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :device_sim_histories do |t|
      t.references :device, null: false, foreign_key: true
      t.references :sim, null: false, foreign_key: true
      t.datetime :installed_at, null: false
      t.datetime :removed_at
      t.string :reasons
      t.timestamps
    end
    add_index :device_sim_histories, [:device_id, :removed_at]
    add_index :device_sim_histories, [:sim_id, :removed_at]
  end
end
