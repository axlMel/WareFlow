class AllowNullUserIdInFolios < ActiveRecord::Migration[8.0]
  def change
    change_column_null :folios, :user_id, true
  end
end
