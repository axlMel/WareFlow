class LaboratoriesController < ApplicationController
  
	def index
    inventory
    render :inventory
  end

  def inventory
    @devices_available = Device.available
    @sims_available = Sim.available

    @recent_connections = DeviceSimHistory
      .includes(:device, :sim)
      .order(installed_at: :desc)
      .limit(10)
  end

  def activate
    device = Device.find(params[:device_id])
    sim = Sim.find(params[:sim_id])

    device.install_sim!(sim)

    redirect_to inventory_laboratories_path,
    notice: "SIM conectada correctamente"
  end
end
