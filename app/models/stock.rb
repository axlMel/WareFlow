class Stock < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :user_id }
end
