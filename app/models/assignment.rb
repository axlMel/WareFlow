class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :delivery, optional: true
  belongs_to :product, optional: true
  belongs_to :device, optional: true
  belongs_to :sim, optional: true

  enum :status, { assigned: 0, installed: 1 }

  # VALIDACIONES

  validates :quantity, numericality: { greater_than: 0 }, if: :product?
  validate :only_one_assignable
  validate :resource_available

  # CALLBACKS

  after_create :apply_effects
  before_destroy :rollback_effects

  # HELPERS

  def product?
    product_id.present?
  end

  def device?
    device_id.present?
  end

  def sim?
    sim_id.present?
  end

  # VALIDACIONES CUSTOM

  def only_one_assignable
    count = [product?, device?, sim?].count(true)

    if count != 1
      errors.add(:base, "Solo puedes asignar un tipo")
    end
  end

  def resource_available
    if device? && !device.available?
      errors.add(:device, "no disponible")
    end

    if sim? && !sim.available?
      errors.add(:sim, "no disponible")
    end
  end

  # EFECTOS (CREATE)

  def apply_effects
    if product?
      move_product_stock(quantity)
    elsif device?
      move_device_stock(+1)
      device.update!(status: :delivered)
    elsif sim?
      move_sim_stock(+1)
      sim.update!(status: :delivered)
    end
  end

  # EFECTOS (DESTROY)

  def rollback_effects
    if product?
      move_product_stock(-quantity)
    elsif device?
      move_device_stock(-1)
      restore_device_status
    elsif sim?
      move_sim_stock(-1)
      restore_sim_status
    end
  end

  # STOCK PRODUCTOS

  def move_product_stock(amount)
    ApplicationRecord.transaction do
      product.with_lock do
        new_stock = product.stock - amount
        raise "Stock insuficiente" if new_stock < 0

        product.update!(stock: new_stock)
      end

      stock = Stock.find_or_create_by!(user: user, product: product)

      stock.with_lock do
        new_qty = stock.quantity + amount
        raise "Stock usuario inválido" if new_qty < 0

        stock.update!(quantity: new_qty)
      end
    end
  end

  # STOCK DEVICE

  def move_device_stock(amount)
    product = device.product

    stock = Stock.find_or_create_by!(user: user, product: product)

    stock.with_lock do
      new_qty = stock.quantity + amount
      raise "Stock negativo" if new_qty < 0

      stock.update!(quantity: new_qty)
    end
  end

  # STOCK SIM

  def move_sim_stock(amount)
    product = sim.product

    stock = Stock.find_or_create_by!(user: user, product: product)

    stock.with_lock do
      new_qty = stock.quantity + amount
      raise "Stock negativo" if new_qty < 0

      stock.update!(quantity: new_qty)
    end
  end

  # RESTORE STATUS

  def restore_device_status
    if device.device_sim_histories.active.exists?
      device.update!(status: :installed)
    else
      device.update!(status: :available)
    end
  end

  def restore_sim_status
    if sim.device_sim_histories.active.exists?
      sim.update!(status: :installed)
    else
      sim.update!(status: :available)
    end
  end
end