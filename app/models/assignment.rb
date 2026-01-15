class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :delivery, optional: true
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validate :quantity_cannot_exceed_product_stock
  validate :cannot_edit_installed, on: :update

  enum :status, { assigned: 0, installed: 1 }

  after_commit :move_stock_to_user, on: :create
  after_update :adjust_stock_by_delta, if: :saved_change_to_quantity?
  before_destroy :restore_stock

  private

  def cannot_edit_installed
    if status_was == "installed"
      errors.add(:base, "No se puede editar una asignación instalada")
    end
  end

  def quantity_cannot_exceed_product_stock
    return unless product && quantity

    available = product.stock + (quantity_before_last_save || 0)
    errors.add(:quantity, "excede el stock disponible") if quantity > available
  end

  def move_stock_to_user
    adjust_stock(quantity)
  end

  def adjust_stock_by_delta
    delta = quantity - quantity_before_last_save
    adjust_stock(delta)
  end

  def adjust_stock(amount)
    ApplicationRecord.transaction do
      product.with_lock do
        product.update!(stock: product.stock - amount)
      end

      stock = Stock.find_or_create_by!(user: user, product: product)
      stock.with_lock do
        stock.update!(quantity: stock.quantity + amount)
      end
    end
  end

  def restore_stock
    adjust_stock(-quantity)
  end
end