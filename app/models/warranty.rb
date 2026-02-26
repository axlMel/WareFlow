class Warranty < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :user
  belongs_to :device, optional: true
  belongs_to :sim, optional: true

  enum :state, { pending: 0, in_process: 1, completed: 2 }

  validates :client, :state, presence: true
  after_initialize :set_default_state, if: :new_record?

  validate :only_one_resource
  after_create :mark_resource_in_warranty

  private

  def set_default_state
    self.state ||= :pending
  end

  def only_one_resource
    resources = [product_id, device_id, sim_id].compact.count
    if resources != 1
      errors.add(:base, "Debe especificarse exactamente un recurso")
    end
  end

  def mark_resource_in_warranty
    if device.present?
      device.device_sim_histories.active.each do |history|
        history.update!(removed_at: Time.current, reasons: "Ingreso a garantía")
      end
      device.update!(status: :in_warranty)
    elsif sim.present?
      sim.update!(status: :in_warranty)
    end
  end
end
