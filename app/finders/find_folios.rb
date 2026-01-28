class FindFolios < ApplicationFinder
	def call
		scoped = @relation.includes(:user)
		scoped = apply_status_filter(scoped)
		scoped = apply_search(scoped)
		scoped = apply_date_filter(scoped)
		scoped.order(created_at: :desc)
	end

  private

  def apply_status_filter(scoped)
    if @params[:status].present?
      scoped.where(status: @params[:status])
    else
      scoped.all
    end
  end
  
  def apply_search(scoped)
    query = @params[:q].to_s.strip
    return scoped if query.blank?

    pattern = "%#{query}%"

    scoped.joins(:user).where(
      "users.username ILIKE :q OR folios.client ILIKE :q OR folios.id::text ILIKE :q",
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