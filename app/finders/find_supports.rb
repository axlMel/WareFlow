class FindSupports < ApplicationFinder
  def call
    scoped = @relation.includes(:product, :user)
    scoped = apply_general_search(scoped) if @params[:q].present?
    scoped = apply_filters(scoped)
    scoped = apply_date_filter(scoped)
    scoped = apply_sorting(scoped)
    scoped
  end

  private

  def apply_general_search(scoped)
    query = @params[:q].to_s.strip

    return scoped if query.blank?

    pattern = "%#{query}%"

    scoped.where(
      "CAST(supports.id AS TEXT) ILIKE :q OR
       CAST(supports.folio_id AS TEXT) ILIKE :q OR
       CAST(supports.user_id AS TEXT) ILIKE :q OR
       CAST(supports.product_id AS TEXT) ILIKE :q OR
       supports.client ILIKE :q OR
       supports.plate ILIKE :q OR
       supports.eco ILIKE :q OR
       supports.commit ILIKE :q OR
       supports.service ILIKE :q",
      q: pattern
    )
  end

  def apply_filters(scoped)
    scoped = scoped.where("supports.client ILIKE ?", "%#{@params[:client]}%") if @params[:client].present?
    scoped = scoped.where(supports: { folio_id: @params[:folio_id] }) if @params[:folio_id].present?
    scoped = scoped.where(supports: { user_id: @params[:user_id] }) if @params[:user_id].present?
    scoped = scoped.where(supports: { product_id: @params[:product_id] }) if @params[:product_id].present?
    scoped = scoped.where("supports.plate ILIKE ?", "%#{@params[:plate]}%") if @params[:plate].present?
    scoped = scoped.where("supports.eco ILIKE ?", "%#{@params[:eco]}%") if @params[:eco].present?
    scoped
  end

  def apply_date_filter(scoped)
    from = parse_date(@params[:from])
    to = parse_date(@params[:to])
    if from && to
      scoped.where(created_at: from.beginning_of_day..to.end_of_day)
    else
      scoped
    end
  end

  def apply_sorting(scoped)
    if @params[:sort].present? && %w[client created_at folio].include?(@params[:sort])
      direction = %w[asc desc].include?(@params[:direction]) ? @params[:direction] : "asc"
      scoped.order(@params[:sort] => direction)
    else
      scoped.order(created_at: :desc)
    end
  end

  def integer_string?(str)
    Integer(str)
    true
  rescue ArgumentError
    false
  end
end
