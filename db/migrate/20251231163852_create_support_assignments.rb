class CreateSupportAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :support_assignments do |t|
      t.references :support, null: false, foreign_key: true
      t.references :assignment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
