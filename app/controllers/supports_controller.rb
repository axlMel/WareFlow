class SupportsController < ApplicationController
  before_action :set_support, only: %i[show edit update destroy]

  def index
    finder = FindSupports.new(Support.all, params)
    scoped = finder.call

    sort_column = params[:sort] || 'created_at'
    sort_direction = params[:direction] == 'desc' ? 'desc' : 'asc'
    scoped = scoped.order("#{sort_column} #{sort_direction}")

    @pagy, @supports = pagy(scoped, items: params[:per_page] || 10)
  end

  def show; end

  def new
    @support = Support.new
    @folios = Folio.where(status: :assigned).includes(:user, deliveries: [:user]) #uso de enum corregido, antes [:product, :user]
    @assignments = []
  end

  def edit; end

  def create
    @support = Support.new(support_params)

    ActiveRecord::Base.transaction do
      @support.save!

      params[:status]&.each do |assignment_id, units|

        unless units.values.all? {|v| v == "used"} 
          raise ActiveRecord::Rollback, "No todos los productos fueron marcados como usados"
        end

        assignment = @support.folio.assignments.find(assignment_id)

        SupportAssignment.create!(
          support: @support,
          assignment: assignment
        )

        assignment.update!(status: :installed)
      end

      @support.folio.update!(status: :delivered)
    end
    redirect_to supports_path, notice: "Soporte creado correctamente."
  rescue => e
    @folios = Folio.where(status: :assigned).includes(:user)
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
    params.require(:support).permit(:service, :client, :folio_id, :user_id, :car_type, :plate, :eco, :commit)
  end
end
