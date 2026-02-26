class Product < ApplicationRecord
  include PgSearch::Model
  include Favoritable
  pg_search_scope :search_full_text, against: {
    title: 'A',
    description: 'B'
  }

  ORDER_BY = {
    newest: "created_at DESC",
    expensive: "price DESC",
    cheapest: "price ASC"
  }

  has_one_attached :photo

  belongs_to :category
  has_many :assignments
  has_many :devices
  has_many :sims

  validates :title, :description, :price, presence: true
  validates :stock, numericality: { greater_than_or_equal_to: 0}

  def broadcast
    broadcast_replace_to self, partial: 'products/product_details', locals: { product: self }
  end

  def real_stock
    return stock unless trackable?

    if devices.exists?
      devices.available.count
    elsif sims.exists?
      sims.available.count
    else
      0
    end
  end
end
