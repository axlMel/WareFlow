class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :delivery, optional: true
  belongs_to :product
  belongs_to :device, optional: true
  belongs_to :sim, optional: true

  validates :quantity, numericality: { greater_than: 0 }
  validate :quantity_cannot_exceed_product_stock, if: :will_save_change_to_quantity?
  validate :cannot_edit_installed, on: :update
  validate :only_one_resource_type

  enum :status, { assigned: 0, installed: 1 }

  after_commit :move_stock_to_user, on: :create
  after_update :adjust_stock_by_delta, if: :saved_change_to_quantity?
  before_destroy :restore_stock
  after_create :update_resource_status
  after_destroy :restore_resource_status

  private

  def update_resource_status
    if device.present?
      device.update!(status: :assigned)
    elsif sim.present?
      sim.update!(status: :assigned)
    end
  end

  def restore_resource_status
    if device.present?
      if device.device_sim_histories.active.exists?
        device.update!(status: :installed)
      else
        device.update!(status: :available)
      end
    elsif sim.present?
      if sim.device_sim_histories.active.exists?
        sim.update!(status: :installed)
      else
        sim.update!(status: :available)
      end
    end
  end

  def only_one_resource_type
    resources = [product_id, device_id, sim_id].compact.count
    if resources != 1
      errors.add(:base, "Debe asignarse exactamente un tipo de recurso")
    end
  end

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

      if product.trackable?
        raise "No se pueden asignar cantidades para productos trackeables"
      else
        product.with_lock do
          product.update!(stock: product.stock - amount)
        end
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