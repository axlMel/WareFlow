class RenameTypeInSupports < ActiveRecord::Migration[8.0]
  def change
    rename_column :supports, :type, :car_type
  end
end
