class FindWarranties < ApplicationFinder

	def call
		scoped = @relation.includes(:user, :product)
		scoped = apply_state_filter(scoped)
		scoped = apply_search(scoped)
		scoped = apply_date_filter(scoped)
		scoped.order(created_at: :desc)
	end

	private

	def apply_state_filter(scoped)
		if @params[:state].present?
			scoped.where(state: @params[:state])
		else
			scoped.all
		end
	end
	
	def apply_search(scoped)
		query = @params[:q].to_s.strip
		return scoped if query.blank?

		pattern = "%#{query}%"

		scoped.joins(:user, :product).where(
			"users.username ILIKE :q OR products.title ILIKE :q OR warranties.client ILIKE :q",
			q: pattern
    )
	end

  def apply_date_filter(scoped)
    from = parse_date(@params[:from])
    to = parse_date(@params[:to])

    return scoped unless from || to
    from ||= 100.years.ago
    to ||= Time.current

    scoped.where(created_at: from.beginning_of_day..to.end_of_day)
  end
end