class SupportAssignment < ApplicationRecord
  belongs_to :support
  belongs_to :assignment

  validate :assignment_belongs_to_support_folio
  add_index :support_assignments, [:support_id, :assignment_id], unique: true

  def assignment_belongs_to_support_folio
    return if assignment.folio_id == support.folio_id
    errors.add(:assignment, "no pertenece al folio del soporte")
  end
end
