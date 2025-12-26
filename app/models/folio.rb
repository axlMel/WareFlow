class Folio < ApplicationRecord
  belongs_to :user, optional: true
  has_many :deliveries
  has_many :assignments, dependent: :nullify

  before_destroy :check_assignments
  enum :status, { crafted: 0, assigned: 1, delivered: 2 }
  

  private

  def check_assignments
    if assignments.exists?
      errors.add(:base, "No puedes eliminar un folio con productos asignados.")
      throw :abort
    end
  end
end
