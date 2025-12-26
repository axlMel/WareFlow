class CorrectSupportReferences < ActiveRecord::Migration[8.0]
  def change
    remove_column :supports, :assignment_id
    remove_column :supports, :user_id
    remove_column :supports, :product_id

    add_reference :supports, :assignment, foreign_key: true
    add_reference :supports, :user, foreign_key: true
    add_reference :supports, :product, foreign_key: true
  end
end
