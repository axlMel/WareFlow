class AddTrackeableBoolToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :trackable, :boolean, default: false, null: false
  end
end
