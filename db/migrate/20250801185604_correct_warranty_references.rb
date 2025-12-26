class CorrectWarrantyReferences < ActiveRecord::Migration[8.0]
  def change
    remove_column :warranties, :assignment_id
    remove_column :warranties, :user_id
    remove_column :warranties, :product_id

    add_reference :warranties, :assignment, foreign_key: true
    add_reference :warranties, :user, foreign_key: true
    add_reference :warranties, :product, foreign_key: true
  end
end
