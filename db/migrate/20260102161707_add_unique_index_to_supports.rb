class AddUniqueIndexToSupports < ActiveRecord::Migration[8.0]
  def change
    add_index :support_assignments,
    [:support_id, :assignment_id],
    unique: true
  end
end
