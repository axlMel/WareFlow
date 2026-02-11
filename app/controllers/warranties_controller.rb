class WarrantiesController < ApplicationController
  before_action :set_warranty, only: [:show, :edit, :update, :destroy]

  def index
    finder = FindWarranties.new(Warranty.all, params)
    scoped = finder.call

    sort_column = params[:sort] || 'warranties.created_at'
    sort_direction = params[:direction] == 'desc' ? 'desc' : 'asc'
    scoped = scoped.reorder("#{sort_column} #{sort_direction}")
    
    @pagy, @warranties = pagy(scoped, items: params[:per_page] || 10)
  end

  def show;
    render layout: false
  end

  def new
    @warranty = Warranty.new
    load_dependencies
  end

  def create
    @warranty = Warranty.new(warranty_params)
    @warranty.state = :pending
    if @warranty.save
      redirect_to warranties_path(show: @warranty.id), notice: "Garantía creada exitosamente.", status: :see_other
    else
      load_dependencies
      flash.now[:alert] = "No se pudo crear la garantía"
      render :new, status: :unprocessable_entity, layout: false
    end
  end

  def edit
    @warranty = Warranty.find(params[:id])
    load_dependencies
    render layout: false
  end

  def update
    if @warranty.update(warranty_params)
      redirect_to warranties_path(show: @warranty.id), notice: "Garantía actualizada exitosamente.", status: :see_other
    else
      load_dependencies
      flash.now[:alert] = "No se pudo actualizar la garantía"
      render :edit, status: :unprocessable_entity, layout: false, notice: "Entrega creada exitosamente y folio asignado."
    end
  end

  def destroy
    @warranty.destroy
    redirect_to warranties_path, notice: "Garantía eliminada exitosamente.", status: :see_other
  end

  def import
  end

  def export
  end

  def download
  end

  def download_base
  end

  private

  def set_warranty
    @warranty = Warranty.find(params[:id])
  end

  def warranty_params
    params.require(:warranty).permit(:client, :user_id, :state, :commit, :product_id)
  end

  def load_dependencies
    @products = Product.all.order(:title)
    @users = User.all.order(:username)
  end
end
