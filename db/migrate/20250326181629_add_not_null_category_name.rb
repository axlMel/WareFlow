class AddNotNullCategoryName < ActiveRecord::Migration[8.0]
  def change
    change_column_null :categories, :name, false
  end
end
