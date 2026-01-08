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

  validates :title, :description, :price, presence: true
  validates :stock, numericality: { greater_than_or_equal_to: 0}


  #has_many :users, through: :assignments
  #has_many :stock_tecnicos
  
  # Calcula available_stock de forma eficiente
  #def self.with_available_stock_for(user)
  #  left_joins(:assignments)
  #    .where(user_id: user.id)
  #    .where('assignments.status = ? OR assignments.id IS NULL', 0)
  #    .group('products.id')
  #    .select(
  #      'products.*',
  #      'COALESCE(SUM(assignments.quantity), 0) AS assigned_quantity'
  #    )
  #end

  #def available_stock
  #  stock - (self.try(:assigned_quantity) || 0)
  #end

  #scope :with_positive_available_stock_for, ->(user) {
  #with_available_stock_for(user).select { |p| p.available_stock > 0 }}

  #def owner?
  #  user_id == Current.user&.id
  #end

  def broadcast
    broadcast_replace_to self, partial: 'products/product_details', locals: { product: self }
  end

end
