# app/controllers/replacements_controller.rb
class ReplacementsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    assignment = Assignment.find(params[:assignment_id])
    replacement_product = Product.find(params[:replacement_product_id])
    commit = params[:commit].presence || "Producto reemplazado por defecto"

    # Buscar el stock del usuario al que pertenece la asignación
    replacement_stock = Stock.find_by(
      user_id: assignment.delivery.folio.user_id,
      product_id: replacement_product.id
    )

    unless replacement_stock
      render json: { error: "No autorizado para usar este producto" }, status: :unauthorized and return
    end

    raise "Stock insuficiente" if replacement_stock.quantity <= 0

    warranty = Warranty.create!(
      assignment_id: assignment.id,
      product_id: replacement_product.id,
      user_id: assignment.delivery.folio.user_id, # el dueño real
      client: assignment.delivery.folio.client,
      state: :pending,
      commit: commit
    )

    replacement_stock.with_lock do
      new_quantity = replacement_stock.quantity - params[:quantity].to_i
      replacement_stock.update!(quantity: new_quantity)
    end


    render json: { success: true, warranty_id: warranty.id }, status: :created
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
