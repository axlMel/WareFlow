class Folio < ApplicationRecord
  belongs_to :user, optional: true
  has_many :deliveries
  has_many :assignments, through: :deliveries

  validate :cannot_edit_delivered, on: :update
  before_destroy :check_assignments
  
  enum :status, { crafted: 0, assigned: 1, delivered: 2 }
  

  private
  def cannot_edit_delivered
    if status_was == "delivered"
      errors.add(:base, "No se puede editar un folio realizado")
    end
  end

  def check_assignments
    if assignments.exists?
      errors.add(:base, "No puedes eliminar un folio con productos asignados.")
      throw :abort
    end
  end
end