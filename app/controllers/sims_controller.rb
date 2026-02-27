class SimsController < ApplicationController
	def index
    @sims = Sim.order(created_at: :desc)
  end

  def new
    @sim = Sim.new
  end

  def create
    @sim = Sim.new(sim_params)

    if @sim.save
      redirect_to sims_path, notice: "SIM creada"
    else
      render :new
    end
  end

  private

  def sim_params
    params.require(:sim).permit(:iccid, :provider, :apn, :phone_number, :product_id)
  end
end
