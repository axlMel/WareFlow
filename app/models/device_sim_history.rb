class DeviceSimHistory < ApplicationRecord
  belongs_to :device
  belongs_to :sim

  validate :only_one_active_sim_per_device
  validate :only_one_active_device_per_sim

  scope :active, -> { where(removed_at: nil) }

  after_create :mark_as_installed
  after_update :mark_as_removed, if: :saved_change_to_removed_at?

  private

  def only_one_active_sim_per_device
    return if removed_at.present?

    if device.device_sim_histories.active.exists?
      errors.add(:device, "ya tiene una SIM activa")
    end
  end

  def only_one_active_device_per_sim
    return if removed_at.present?

    if sim.device_sim_histories.active.exists?
      errors.add(:sim, "ya está instalada en otro device")
    end
  end
  def mark_as_installed
    device.update!(status: :installed)
    sim.update!(status: :installed)
  end

  def mark_as_removed
    sim.update!(status: :available)

    unless device.assignments.exists?
      device.update!(status: :available)
    end
  end
end