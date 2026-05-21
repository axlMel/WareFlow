class RemoveNotNullFromProductIdInAssignments < ActiveRecord::Migration[8.0]
  def change
    change_column_null :assignments, :product_id, true
  end
end
