class LaboratoryController < ApplicationController
	def index
    @devices = Device.includes(:device_sim_histories)
                     .order(created_at: :desc)

    @available_sims = Sim.available
  end
end
