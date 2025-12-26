class Folios::ApiController < ApplicationController
  before_action :set_folio, only: [:data, :products]

  def data
    request.format = :json
    render json: {
      folio_id: @folio.id,
      user: @folio.user&.username,
      user_id: @folio.user_id,
      client: @folio.client,
      status: @folio.status,
      service: @folio.service
    }
  end

  def products
    @folio = Folio.includes(deliveries: { assignments: { product: :category } }).find(params[:id])

    grouped_products = Hash.new { |h, k| h[k] = [] }

    # Obtener categorías presentes en el folio
    category_ids = @folio.deliveries.flat_map do |delivery|
      delivery.assignments.map { |a| a.product.category_id }
    end.uniq

    # Filtrar productos de reemplazo por usuario y categoría usando tabla STOCK
    stock_items = Stock
      .includes(:product)
      .where(user_id: @folio.user_id)
      .where("quantity > 0")
      .select { |s| category_ids.include?(s.product.category_id) }

    replacements_by_category = stock_items
      .group_by { |s| s.product.category_id }
      .transform_values do |stocks|
        stocks.select { |s| s.quantity.to_i > 0 }.map do |stock|
          product = stock.product
          product.define_singleton_method(:stock_quantity) { stock.quantity }
          product
        end
      end

    # Construir estructura visual
    @folio.deliveries.each do |delivery|
      delivery.assignments.each do |assignment|
        product = assignment.product
        category_name = product.category.name
        category_id = product.category_id

        quantity = assignment.quantity || 1

        quantity.times do |i|
          grouped_products[category_name] << {
            assignment_id: assignment.id,
            product_id: product.id,
            title: product.title,
            category: category_name,
            index: i + 1, # opcional, para mostrar "unidad 1", "unidad 2", etc.
            replacements: replacements_by_category[category_id] || []
          }
        end
      end
    end

    html = render_to_string partial: "supports/category_group",
                            locals: { grouped_products: grouped_products },
                            formats: [:html]

    render html: html.html_safe
  end

  private

  def set_folio
    @folio = Folio.find_by(id: params[:id])
    unless @folio
      render json: { error: "Folio no encontrado" }, status: :not_found and return
    end
  end
end
