class RemoveAssignmentFromWarranties < ActiveRecord::Migration[8.0]
  def change
    remove_reference :warranties, :assignment, foreign_key: true
  end
end
