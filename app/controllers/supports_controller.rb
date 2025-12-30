class SupportsController < ApplicationController
  before_action :set_support, only: %i[show edit update destroy]

  def index
    finder = FindSupports.new(Support.all, params)
    scoped = finder.call

    sort_column = params[:sort] || 'created_at'
    sort_direction = params[:direction] == 'desc' ? 'desc' : 'asc'
    scoped = scoped.order("#{sort_column} #{sort_direction}")

    @pagy, @supports = pagy(scoped, items: params[:per_page] || 10)

    @users = User.where(admin: false)
    @clients = Support.distinct.pluck(:client).compact
    @folios = Support.distinct.pluck(:folio_id).compact

    respond_to do |format|
      format.html
    end
  end

  def show; end

  def new
    @support = Support.new
    @folios = Folio.where(status: :assigned).includes(:user, assignments: [:product, :user]) #uso de enum corregido
    @assignments = []
  end

  def edit; end

  def create
    @support = Support.new(support_params)

    ActiveRecord::Base.transaction do
      @support.save!

      # 1. Cambiar el status del folio a "instalado"
      @support.folio.update!(status: "Instalado")

      # 2. Cambiar status de asignaciones marcadas como "used"
      params[:status]&.each do |assignment_key, value|
        next unless value == "used" # Solo procesar los marcados como "used"

        assignment = Assignment.find_by(id: assignment_key)
        next unless assignment # ignorar si no existe

        assignment.update!(status: :installed) unless assignment.installed?
      end
    end

    redirect_to supports_path, notice: "Soporte creado correctamente."
  rescue => e
    @folios = Folio.where(status: :crafted).includes(:user)
    flash.now[:alert] = "Error al crear soporte: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def update
    if @support.update(support_params)
      redirect_to @support, notice: "Soporte actualizado correctamente."
    else
      render :edit
    end
  end

  def destroy
    @support.destroy
    redirect_to supports_url, notice: "Soporte eliminado."
  end

  private

  def set_support
    @support = Support.find(params[:id])
  end

  def support_params
    params.require(:support).permit(:service, :client, :product_id, :folio_id, :user_id, :car_type, :plate, :eco, :commit)
  end
end
