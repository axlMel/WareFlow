class Warranty < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :assignment

  enum :state, { pending: 0, in_process: 1, completed: 2 }

  validates :client, :state, presence: true
end
