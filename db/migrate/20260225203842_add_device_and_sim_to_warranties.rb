class AddDeviceAndSimToWarranties < ActiveRecord::Migration[8.0]
  def change
    add_reference :warranties, :device, foreign_key: true
    add_reference :warranties, :sim, foreign_key: true
  end
end
