class MakeDeliveryOptionalInAssignments < ActiveRecord::Migration[8.0]
  def change
     change_column_null :assignments, :delivery_id, true
  end
end
