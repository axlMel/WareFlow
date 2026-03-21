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

  def assign_sim!(sim:, reason:)
    raise ArgumentError, "Debes seleccionar una SIM." if sim.blank?
    raise ArgumentError, "Debes indicar el motivo de la asignación." if reason.blank?
    raise StandardError, "Este dispositivo ya tiene una SIM activa." if active_history.present?

    transaction do
      device_sim_histories.create!(
        sim: sim,
        installed_at: Time.current,
        reasons: nil
      )

      sim.assigned! if sim.respond_to?(:assigned!)
      assigned!
    end
  end

  def replace_sim!(new_sim:, reason:)
    raise ArgumentError, "Debes seleccionar una SIM." if new_sim.blank?
    raise ArgumentError, "Debes indicar el motivo del reemplazo." if reason.blank?

    current_history = active_history
    raise StandardError, "El dispositivo no tiene una SIM activa para reemplazar." if current_history.blank?

    transaction do
      current_history.update!(
        removed_at: Time.current,
        reasons: reason
      )

      current_history.sim.available! if current_history.sim.respond_to?(:available!)

      device_sim_histories.create!(
        sim: new_sim,
        installed_at: Time.current,
        reasons: nil
      )

      new_sim.assigned! if new_sim.respond_to?(:assigned!)
      assigned!
    end
  end

  def remove_sim!(reason:)
    raise ArgumentError, "Debes indicar el motivo de la desasociación." if reason.blank?

    current_history = active_history
    raise StandardError, "El dispositivo no tiene una SIM activa para quitar." if current_history.blank?

    transaction do
      current_history.update!(
        removed_at: Time.current,
        reasons: reason
      )

      current_history.sim.available! if current_history.sim.respond_to?(:available!)
      available!
    end
  end

  def send_to_warranty!(reason:)
    raise ArgumentError, "Debes indicar el motivo de garantía." if reason.blank?

    transaction do
      if active_history.present?
        active_history.update!(
          removed_at: Time.current,
          reasons: reason
        )

        active_history.sim.available! if active_history.sim.respond_to?(:available!)
      end

      in_warranty!
    end
  end

  def mark_as_damaged!(reason:)
    raise ArgumentError, "Debes indicar el motivo del daño." if reason.blank?

    transaction do
      if active_history.present?
        active_history.update!(
          removed_at: Time.current,
          reasons: reason
        )

        active_history.sim.available! if active_history.sim.respond_to?(:available!)
      end

      damaged!
    end
  end

  def mark_as_returned!(reason:)
    raise ArgumentError, "Debes indicar el motivo de la devolución." if reason.blank?

    transaction do
      if active_history.present?
        active_history.update!(
          removed_at: Time.current,
          reasons: reason
        )

        active_history.sim.available! if active_history.sim.respond_to?(:available!)
      end

      returned!
    end
  end

  def active_history
    @active_history ||= device_sim_histories.active.includes(:sim).first
  end

  def current_sim
    active_history&.sim
  end

  def active_sim
    current_sim
  end

  def current_holder
    assignments.last&.user
  end
end