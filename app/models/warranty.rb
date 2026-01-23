class Warranty < ApplicationRecord
  belongs_to :product
  belongs_to :user

  enum :state, { pending: 0, in_process: 1, completed: 2 }

  validates :client, :state, presence: true
end
