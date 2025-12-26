class Support < ApplicationRecord
	include PgSearch::Model
	belongs_to :folio
	belongs_to :assignment
	belongs_to :product, optional: true
	belongs_to :user, optional: true

	pg_search_scope :global_search,
		against: [:client, :service, :plate, :eco, :commit],
		associated_against: {
			product:[:title],
			user: [:username]
		},
		using: {
			tsearch: { prefix: true, any_word: true }
		}
end
