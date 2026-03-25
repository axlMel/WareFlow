class DeviceMovement < ApplicationRecord
  belongs_to :device
  belongs_to :sim, optional: true

  enum :movement_type, {
    created: 0,
    sim_assigned: 1,
    sim_replaced: 2,
    sim_removed: 3,
    installed_in_client: 4,
    sent_to_warranty: 5,
    marked_damaged: 6,
    returned_to_provider: 7
  }

  validates :movement_type, presence: true
  validates :reason, presence: true
  validates :performed_at, presence: true
end