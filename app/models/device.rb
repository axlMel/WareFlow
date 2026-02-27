class Device < ApplicationRecord
  belongs_to :product
  has_many :device_sim_histories, dependent: :destroy
  has_many :assignments

  enum :status, {
    available: 0, #en almacen listo para salir
    assigned: 1, #asignado a una sim
    installed: 2, # en un vehiculo de cliente "vendido"
    in_warranty: 3, #ingresado a laboratorio
    damaged: 4, #Dado de baja por daño irreparable
    returned: 5 #garantía interna(devuelta a proveedor)
  }

  validates :imei, presence: true, uniqueness: true
  before_update :prevent_stock_change_if_trackable
  has_many :device_sim_histories

  def current_sim
    device_sim_histories
      .where(removed_at: nil)
      .includes(:sim)
      .first
      &.sim
  end

  def prevent_stock_change_if_trackable
    if trackable? && stock_changed?
      errors.add(:stock, "No puede modificarse directamente en productos trackeables")
      throw(:abort)
    end
  end

  def active_sim
    device_sim_histories.active.first&.sim
  end

  def current_holder
    assignments.last&.user
  end

end