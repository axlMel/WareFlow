class RemoveAssignmentFromSupports < ActiveRecord::Migration[8.0]
  def change
    remove_reference :supports, :assignment, null: false, foreign_key: true
  end
end
