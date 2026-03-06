class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy]

  def index
    @devices = Device.includes(:product).order(created_at: :desc)
  end

  def show
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

  def edit
  end

  def update
    if @device.update(device_params)
      redirect_to devices_path, notice: "Device actualizado"
    else
      render :edit
    end
  end

  def destroy
    @device.destroy
    redirect_to devices_path, notice: "Device eliminado"
  end

  private

  def set_device
    @device = Device.find(params[:id])
  end

  def device_params
    params.require(:device).permit(:imei, :brand, :model, :product_id)
  end
end