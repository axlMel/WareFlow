class Sim < ApplicationRecord
  belongs_to :product
  has_many :device_sim_histories, dependent: :destroy
  has_many :assignments

  enum :status, {
    available: 0,
    assigned: 1,
    installed: 2,
    in_warranty: 3,
    damaged: 4,
    returned: 5
  }
  scope :available, -> { where(status: :available) }

  validates :iccid, presence: true, uniqueness: true

  def current_device
    device_sim_histories.active.first&.device
  end
end