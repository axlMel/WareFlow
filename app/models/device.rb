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

  def install_sim!(sim)
    transaction do
      active_history = device_sim_histories.active.first

      if active_history
        active_history.update!(
          removed_at: Time.current,
          reasons: "SIM reemplazada"
        )
      end

      device_sim_histories.create!(
        sim: sim,
        installed_at: Time.current
      )
    end
  end

  def remove_sim!
    active_history = device_sim_histories.active.first
    return unless active_history

    active_history.update!(
      removed_at: Time.current,
      reasons: "SIM removida en laboratorio"
    )
  end

  def current_sim
    device_sim_histories
      .where(removed_at: nil)
      .includes(:sim)
      .first
      &.sim
  end

  def active_sim
    device_sim_histories.active.first&.sim
  end

  def current_holder
    assignments.last&.user
  end

end