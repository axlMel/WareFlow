class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :delivery
  belongs_to :product
  belongs_to :folio, optional: true

  validates :quantity, numericality: { greater_than: 0 }
  validate :quantity_cannot_exceed_stock

  enum :status, { assigned: 0, installed: 1 }

  after_create :decrement_product_stock
  after_update :adjust_product_stock_on_update
  after_destroy :restore_product_stock

  private

  def quantity_cannot_exceed_stock
    return unless product && quantity

    if quantity > product.available_stock
      errors.add(:quantity, "excede el stock disponible (#{product.available_stock})")
    end
  end

  def decrement_product_stock
    return if product.stock.nil?
    product.decrement!(:stock, quantity)
  end

  def adjust_product_stock_on_update
    return if product.stock.nil?
    if saved_change_to_quantity?
      stock_diff = quantity_before_last_save - quantity
      product.increment!(:stock, stock_diff)
    end
  end

  def restore_product_stock
    return if product.stock.nil?
    product.increment!(:stock, quantity)
  end
end