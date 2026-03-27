class Device < ApplicationRecord
  belongs_to :product
  has_many :device_sim_histories, dependent: :destroy
  has_many :assignments
  has_many :device_movements, dependent: :destroy

  after_create :register_created_movement!

  enum :status, {
    available: 0, #en almacen listo para salir
    assigned: 1, #asignado a una sim
    installed: 2, # en un vehiculo de cliente "vendido"
    in_warranty: 3, #ingresado a laboratorio
    damaged: 4, #Dado de baja por daño irreparable
    returned: 5, #garantía interna(devuelta a proveedor)
    delivered:6
  }

  validates :imei, presence: true, uniqueness: true

  def install_sim!(sim, reason: "Asignación de SIM")
    raise ArgumentError, "Debes seleccionar una SIM." if sim.blank?
    raise ArgumentError, "La SIM seleccionada no está disponible." unless sim.available?

    transaction do
      previous_status = self.class.statuses[status]

      active_history = device_sim_histories.active.first
      raise ArgumentError, "Este dispositivo ya tiene una SIM activa." if active_history.present?

      device_sim_histories.create!(
        sim: sim,
        installed_at: Time.current
      )

      sim.assigned! if sim.respond_to?(:assigned!)
      assigned!

      register_movement!(
        movement_type: :sim_assigned,
        sim: sim,
        reason: reason,
        from_status: previous_status,
        to_status: self.class.statuses[status]
      )
    end
  end

  def mark_as_installed!(reason: "Instalación en vehículo")
    transaction do
      previous_status = self.class.statuses[status]
      current_active_sim = active_sim

      installed!

      register_movement!(
        movement_type: :installed,
        sim: current_active_sim,
        reason: reason,
        from_status: previous_status,
        to_status: self.class.statuses[status]
      )
    end
  end

  def replace_sim!(sim, reason:)
    raise ArgumentError, "Debes seleccionar una SIM." if sim.blank?
    raise ArgumentError, "Debes indicar el motivo del reemplazo." if reason.blank?
    raise ArgumentError, "La SIM seleccionada no está disponible." unless sim.available?

    transaction do
      active_history = device_sim_histories.active.first
      raise ArgumentError, "No hay una SIM activa para reemplazar." unless active_history.present?

      previous_status = self.class.statuses[status]
      previous_sim = active_history.sim

      active_history.update!(
        removed_at: Time.current,
        reasons: reason
      )

      previous_sim.available! if previous_sim.respond_to?(:available!)

      device_sim_histories.create!(
        sim: sim,
        installed_at: Time.current
      )

      sim.assigned! if sim.respond_to?(:assigned!)
      assigned! unless installed?

      register_movement!(
        movement_type: :sim_replaced,
        sim: sim,
        reason: reason,
        from_status: previous_status,
        to_status: self.class.statuses[status]
      )
    end
  end

  def remove_sim!(reason:)
    raise ArgumentError, "Debes indicar el motivo para quitar la SIM." if reason.blank?

    transaction do
      active_history = device_sim_histories.active.first
      raise ArgumentError, "No hay una SIM activa para remover." unless active_history.present?

      previous_status = self.class.statuses[status]
      removed_sim = active_history.sim

      active_history.update!(
        removed_at: Time.current,
        reasons: reason
      )

      removed_sim.available! if removed_sim.respond_to?(:available!)
      available!

      register_movement!(
        movement_type: :sim_removed,
        sim: removed_sim,
        reason: reason,
        from_status: previous_status,
        to_status: self.class.statuses[status]
      )
    end
  end

  def send_to_warranty!(reason:)
    raise ArgumentError, "Debes indicar el motivo de garantía." if reason.blank?

    transaction do
      previous_status = self.class.statuses[status]

      in_warranty!

      register_movement!(
        movement_type: :sent_to_warranty,
        sim: active_sim,
        reason: reason,
        from_status: previous_status,
        to_status: self.class.statuses[status]
      )
    end
  end

  def mark_as_damaged!(reason:)
    raise ArgumentError, "Debes indicar el motivo del daño." if reason.blank?

    transaction do
      previous_status = self.class.statuses[status]
      current_active_sim = active_sim
      active_history = device_sim_histories.active.first

      if active_history.present?
        active_history.update!(
          removed_at: Time.current,
          reasons: reason
        )

        current_active_sim&.available!
      end

      damaged!

      register_movement!(
        movement_type: :marked_damaged,
        sim: current_active_sim,
        reason: reason,
        from_status: previous_status,
        to_status: self.class.statuses[status]
      )
    end
  end

  def mark_as_returned!(reason:)
    raise ArgumentError, "Debes indicar el motivo de la devolución." if reason.blank?

    transaction do
      previous_status = self.class.statuses[status]
      current_active_sim = active_sim
      active_history = device_sim_histories.active.first

      if active_history.present?
        active_history.update!(
          removed_at: Time.current,
          reasons: reason
        )

        current_active_sim&.available!
      end

      returned!

      register_movement!(
        movement_type: :returned_to_provider,
        sim: current_active_sim,
        reason: reason,
        from_status: previous_status,
        to_status: self.class.statuses[status]
      )
    end
  end

  def active_history
    device_sim_histories.active.includes(:sim).first
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

  private

  def register_movement!(movement_type:, reason:, sim: nil, from_status: nil, to_status: nil)
    device_movements.create!(
      sim: sim,
      movement_type: movement_type,
      from_status: from_status,
      to_status: to_status,
      reason: reason,
      performed_at: Time.current
    )
  end

  def register_created_movement!
    register_movement!(
      movement_type: :created,
      reason: "Alta del dispositivo",
      to_status: self.class.statuses[status]
    )
  end
end