class RemoveFolioIdFromAssignments < ActiveRecord::Migration[8.0]
  def change
    remove_column :assignments, :folio_id, :bigint
  end
end
