class DeliveriesController < ApplicationController
  before_action :set_delivery, only: %i[show edit update destroy]

  def index
    @deliveries = Delivery.includes(:user, :assignments, :products).all
    @users = User.where(admin: false)
  end

  def show
    @assignments = @delivery.assignments.includes(:product)
    
  end

  def new
    @delivery = Delivery.new
    @delivery.assignments.build if @delivery.assignments.empty? # Para tener al menos una fila lista
    load_dependencies
  end

  def create
    @delivery = Delivery.new(delivery_params)
    folio = Folio.find(@delivery.folio_id)
    @delivery.client = folio.client
    @delivery.user_id = delivery_params[:user_id]

    @delivery.assignments.each do |assignment|
      assignment.folio_id = @delivery.folio_id
      assignment.user_id = @delivery.user_id
    end

    # Validar si hay suficiente stock para cada producto
    stock_errors = []

    @delivery.assignments.each do |assignment|
      product = assignment.product
      quantity = assignment.quantity

      if product.stock < quantity
        stock_errors << "Stock insuficiente para el producto #{product.title}"
      end
    end

    if !@delivery.valid? || stock_errors.any?
      flash.now[:alert] = @delivery.errors.full_messages + stock_errors
      load_dependencies
      return render :new, status: :unprocessable_entity
    end

    # Si todo es válido y el stock es suficiente, hacer la transacción
    ActiveRecord::Base.transaction do
      @delivery.save!

      # @delivery.assignments.each do |assignment|
      #   product = assignment.product
      #   quantity = assignment.quantity
      #   product.update!(stock: product.stock - quantity)
      # end

      folio.user_id = @delivery.user_id
      folio.status = "Asignado"
      folio.save!
    end

    redirect_to @delivery, notice: "Entrega creada exitosamente y folio asignado."

  rescue => e
    Rails.logger.error "Error al crear entrega: #{e.message}"
    flash.now[:alert] = @delivery.errors.full_messages.presence || ["Ocurrió un error al crear la entrega."]
    load_dependencies
    render :new, status: :unprocessable_entity
  end


  def edit
    @users = User.where(admin: false)
    @delivery = Delivery.find(params[:id])
    @assignments = @delivery.assignments.includes(:product)
  end

  def update
    @delivery = Delivery.find(params[:id])
    previous_assignments = @delivery.assignments.index_by(&:id)
    stock_errors = []
    @users = User.where(admin: false)

    ActiveRecord::Base.transaction do
      if @delivery.update(delivery_params)
        @delivery.assignments.each do |assignment|
          product = assignment.product
          previous = previous_assignments[assignment.id]

          if assignment.marked_for_destruction?
            product.update!(stock: product.stock + previous.quantity) if previous
            next
          end

          if previous.nil?
            if product.stock < assignment.quantity
              stock_errors << "Stock insuficiente para el producto #{product.title}"
              raise ActiveRecord::Rollback
            else
              product.update!(stock: product.stock - assignment.quantity)
            end

          elsif previous.quantity != assignment.quantity
            diff = assignment.quantity - previous.quantity
            if product.stock < diff
              stock_errors << "Stock insuficiente para el producto #{product.title}"
              raise ActiveRecord::Rollback
            else
              product.update!(stock: product.stock - diff)
            end
          end
        end

        if delivery_params[:folio_attributes].present?
          @delivery.folio.update!(
            user_id: delivery_params[:folio_attributes][:user_id]
          )
        end

        redirect_to @delivery, notice: "Entrega y asignaciones actualizadas."
      else
        raise ActiveRecord::Rollback
      end
    end

  rescue => e
    Rails.logger.error "Error al actualizar entrega: #{e.message}"
    flash.now[:alert] = stock_errors.presence || ["Ocurrió un error al actualizar."]
    @assignments = @delivery.assignments.includes(:product)
    render :edit, status: :unprocessable_entity and return
  end




  def destroy
    @delivery.destroy
    redirect_to deliveries_path, notice: 'Entrega eliminada.'
  end

  private
  def set_users
    @users = User.where(admin: false)
  end

  def set_delivery
    @delivery = Delivery.find(params[:id])
  end

  def delivery_params
    params.require(:delivery).permit(:user_id, :client, :folio_id,
      assignments_attributes: [:id, :product_id, :quantity, :status,:folio_id, :user_id, :_destroy], folio_attributes: [:id, :user_id, :status])
  end

  def load_dependencies
    @products = Product.all.index_by(&:id)
    @folios = Folio.where(status: :crafted)
    @users = User.where(admin: false)
  end
end