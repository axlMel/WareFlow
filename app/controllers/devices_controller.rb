class DevicesController < ApplicationController
	def index
    @devices = Device.includes(:product).order(created_at: :desc)
  end

  def new
    @device = Device.new
  end

  def create
    @device = Device.new(device_params)

    if @device.save
      redirect_to devices_path, notice: "Device creado"
    else
      render :new
    end
  end

  private

  def device_params
    params.require(:device).permit(:imei, :brand, :model, :product_id)
  end
end
