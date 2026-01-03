class SupportAssignment < ApplicationRecord
  belongs_to :support
  belongs_to :assignment

  validate :assignment_belongs_to_support_folio

  def assignment_belongs_to_support_folio
    return if assignment.folio_id == support.folio_id
    errors.add(:assignment, "no pertenece al folio del soporte")
  end
end
