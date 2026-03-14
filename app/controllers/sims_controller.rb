class SimsController < ApplicationController
  before_action :set_sim, only: [:show, :edit, :update, :destroy]

  def index
    finder = FindSims.new(Sim.all, params)
    scoped = finder.call

    sort_column = params[:sort] || 'created_at'
    sort_direction = params[:direction] == 'desc' ? 'desc' : "asc"
    scoped = scoped.order("#{sort_column} #{sort_direction}")

    @pagy, @sims = pagy(scoped, items: params[:per_page] || 10)
  end

  def show
  end

  def new
    @sim = Sim.new
    @products = Product.where(category: 785039888)
  end

  def create
    @sim = Sim.new(sim_params)

    if @sim.save
      redirect_to sims_path, notice: "SIM creada"
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace( "modal", template: "sims/new", layout: false, locals: { sim: @sim }), status: :unprocessable_entity
        end

        format.html do
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
  end

  def update
    if @sim.update(sim_params)
      redirect_to sims_path, notice: "SIM actualizada"
    else
      render :edit
    end
  end

  def destroy
    @sim.destroy
    redirect_to sims_path, notice: "SIM eliminada"
  end

  private

  def set_sim
    @sim = Sim.find(params[:id])
  end

  def sim_params
    params.require(:sim).permit(:iccid, :provider, :apn, :phone_number, :product_id)
  end
end