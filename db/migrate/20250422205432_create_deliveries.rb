class CreateDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table :deliveries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :client
      t.integer :folio

      t.timestamps
    end
  end
end
