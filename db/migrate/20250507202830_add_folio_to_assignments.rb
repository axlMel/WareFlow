class AddFolioToAssignments < ActiveRecord::Migration[8.0]
  def change
    add_reference :assignments, :folio, null: false, foreign_key: true
  end
end
