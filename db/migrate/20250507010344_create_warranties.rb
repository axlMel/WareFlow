class CreateWarranties < ActiveRecord::Migration[8.0]
  def change
    create_table :warranties do |t|
      t.bigint :product_id
      t.string :client
      t.bigint :user_id
      t.text :commit
      t.bigint :assignment_id
      t.integer :state

      t.timestamps
    end
  end
end
