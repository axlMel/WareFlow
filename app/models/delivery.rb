class Delivery < ApplicationRecord
  belongs_to :user
  belongs_to :folio, optional: false
  has_many :assignments, dependent: :destroy
  has_many :products, through: :assignments

  validates :folio, :client, presence: true
  validates :user, presence: true
end
