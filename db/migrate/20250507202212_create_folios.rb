class CreateFolios < ActiveRecord::Migration[8.0]
  def change
    create_table :folios do |t|
      t.string :client
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
