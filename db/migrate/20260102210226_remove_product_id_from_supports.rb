class RemoveProductIdFromSupports < ActiveRecord::Migration[8.0]
  def change
    remove_column :supports, :product_id, :bigint
  end
end
