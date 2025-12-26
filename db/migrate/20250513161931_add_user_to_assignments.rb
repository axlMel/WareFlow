class AddUserToAssignments < ActiveRecord::Migration[8.0]
  def change
    add_reference :assignments, :user, null: false, foreign_key: true
  end
end
