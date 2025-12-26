class WarrantiesController < ApplicationController
  before_action :set_warranty, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
    @warranties = Warranty.includes(:user, :assignment).order(created_at: :desc)

    # Filtros de búsqueda
    @warranties = @warranties.where("client ILIKE ?", "%#{params[:client]}%") if params[:client].present?
    @warranties = @warranties.where(id: params[:folio]) if params[:folio].present?
    @warranties = @warranties.where(user_id: params[:user_id]) if params[:user_id].present?
    @warranties = @warranties.where(state: params[:status]) if params[:status].present?
  end

  def new
    @warranty = Warranty.new
    @products = Product.all  # ✅ Agrega esto
    @users = User.all        # Opcional si también lo necesitas en el formulario
  end

  def create
   
    @warranty = Warranty.new
    @products = Product.all  # ✅ Agrega esto
    @users = User.all        # Opcional si también lo necesitas en el formulario


    @warranty = Warranty.new(warranty_params)
    if @warranty.save
      redirect_to warranties_path, notice: "Garantía creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @warranty = Warranty.new
    @products = Product.all  # ✅ Agrega esto
    @users = User.all      
  end

  def update
    if @warranty.update(warranty_params)
      redirect_to warranties_path, notice: "Garantía actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @warranty.destroy
    redirect_to warranties_path, notice: "Garantía eliminada exitosamente."
  end

  private

  def set_warranty
    @warranty = Warranty.find(params[:id])
  end

  def warranty_params
    params.require(:warranty).permit(:client, :user_id, :assignment_id, :state, :commit)
  end
end
