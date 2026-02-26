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

  validates :iccid, presence: true, uniqueness: true
end