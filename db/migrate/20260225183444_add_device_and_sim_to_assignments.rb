class AddDeviceAndSimToAssignments < ActiveRecord::Migration[8.0]
  def change
    add_reference :assignments, :device, foreign_key: true
    add_reference :assignments, :sim, foreign_key: true
  end
end
