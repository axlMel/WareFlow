class LaboratoriesController < ApplicationController
	def index
    @devices = Device.includes(:device_sim_histories)
                     .order(created_at: :desc)

    @available_sims = Sim.where(status: :available)
  end

  def install_sim
    device = Device.find(params[:device_id])
    sim = Sim.find(params[:sim_id])

    device.install_sim!(sim)

    redirect_to laboratory_path, notice: "SIM instalada correctamente"
  end
end
