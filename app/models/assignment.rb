class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :delivery, optional: true
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validate :quantity_cannot_exceed_product_stock

  enum :status, { assigned: 0, installed: 1 }

  after_create :move_stock_to_user
  before_update :revert_previous_stock, if: :stock_relevant_changes?
  after_update :apply_new_stock, if: :stock_relevant_changes?
  before_destroy :restore_stock

  private

  def quantity_cannot_exceed_product_stock
    return unless product && quantity

    if quantity > product.stock
      errors.add(:quantity, "excede el stock disponible en bodega (#{product.stock})")
    end
  end

  def move_stock_to_user
    ApplicationRecord.transaction do
      product.with_lock do
        product.update!(stock: product.stock - quantity)
      end

      stock = Stock.find_or_create_by!(user: user, product: product)
      stock.with_lock do
        stock.update!(quantity: stock.quantity + quantity)
      end
    end
  end

  def stock_relevant_changes?
    saved_change_to_quantity? || saved_change_to_product_id?
  end

  def revert_previous_stock
    previous_quantity = quantity_before_last_save || quantity
    previous_product = Product.find(product_id_before_last_save)

    ApplicationRecord.transaction do
      previous_product.with_lock do
        previous_product.update!(
          stock: previous_product.stock + previous_quantity
        )
      end

      stock = Stock.find_by(user: user, product: previous_product)
      stock&.with_lock do
        stock.update!(quantity: stock.quantity - previous_quantity)
      end
    end
  end

  def apply_new_stock
    ApplicationRecord.transaction do
      product.with_lock do
        product.update!(stock: product.stock - quantity)
      end

      stock = Stock.find_or_create_by!(user: user, product: product)
      stock&.with_lock do
        stock.update!(quantity: stock.quantity + quantity)
      end
    end
  end

  def restore_stock
    ApplicationRecord.transaction do
      product.with_lock do
        product.update!(stock: product.stock + quantity)
      end

      stock = Stock.find_by(user: user, product: product)
      stock&.with_lock do
        stock.update!(quantity: stock.quantity - quantity)
      end
    end
  end
end