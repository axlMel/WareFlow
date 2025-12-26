class Delivery < ApplicationRecord
  belongs_to :user
  belongs_to :folio
  has_many :assignments, inverse_of: :delivery, dependent: :destroy
  has_many :products, through: :assignments


  validates :folio, :client, presence: true
  accepts_nested_attributes_for :assignments, allow_destroy: true
  accepts_nested_attributes_for :folio
end
