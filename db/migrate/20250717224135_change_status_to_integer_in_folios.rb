class ChangeStatusToIntegerInFolios < ActiveRecord::Migration[8.0]
  def change
    # Primero elimina o cambia el tipo de columna status
    remove_column :folios, :status, :string

    # Luego vuelve a agregarla como integer con default 0 (created)
    add_column :folios, :status, :integer, default: 0, null: false
  end
end
