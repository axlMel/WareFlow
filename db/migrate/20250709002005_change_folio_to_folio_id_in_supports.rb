class ChangeFolioToFolioIdInSupports < ActiveRecord::Migration[8.0]
  def change
    # Elimina la columna antigua
    remove_column :supports, :folio, :integer

    # Agrega la nueva columna folio_id como referencia (bigint + foreign key)
    add_reference :supports, :folio, foreign_key: true, type: :bigint
  end
end
