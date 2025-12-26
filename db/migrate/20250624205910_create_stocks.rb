class CreateStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 0

      t.timestamps
    end
    add_index :stocks, [:product_id, :user_id], unique: true
  end
end
