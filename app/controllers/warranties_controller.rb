class WarrantiesController < ApplicationController
  before_action :set_warranty, only: [:show, :edit, :update, :destroy]

  def index
    finder = FindWarranties.new(Warranty.all, params)
    scoped = finder.call

    sort_column = params[:sort] || 'warranties.created_at'
    sort_direction = params[:direction] == 'asc' ? 'asc' : 'desc'
    scoped = scoped.reorder("#{sort_column} #{sort_direction}")
    
    per_page = params[:per_page].presence&.to_i || 10
    @pagy, @warranties = pagy(scoped, items: per_page, limit: per_page)
  end

  def show
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
      
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            template: "warranties/new",
            layout: false,
            locals: { warranty: @warranty }
          ), status: :unprocessable_entity
        end
        format.html do
          render :new, status: :unprocessable_entity
        end
      end
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
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            template: "warranties/new",
            layout: false,
            locals: { warranty: @warranty }
          ), status: :unprocessable_entity
        end
        format.html do
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    if @warranty.destroy
      redirect_to warranties_path, notice: "Garantía eliminada exitosamente.", status: :see_other
    else
      redirect_to warranties_path, alert: @warranty.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def import
    if request.get?
      render partial: "shared/import"
      return
    end

    file = params[:file]
    redirect_to folios_path, alert: "Archivo requerido" and return unless file
    parser = Imports::Warranties::Parser.new(file)
    @rows = parser.parse
    render :preview
  end

  def manual
    @rows = [Imports::Warranties::Builder.empty_row]
    render :preview
  end

  def confirm_import
    rows = params[:rows]

    Imports::Warranties::Persister.new(rows).persist!

    redirect_to warranties_path, notice: "Importación exitosa"
  end


  def download_base
  end

  def export
  end

  def download
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
