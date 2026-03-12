class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy]

  def index
    finder = FindDevices.new(Device.all, params)
    scoped = finder.call

    sort_column = params[:sort] || 'created_at'
    sort_direction = params[:direction] == 'desc' ? 'desc' : 'asc'
    scoped = scoped.order("#{sort_column} #{sort_direction}")

    @pagy, @devices = pagy(scoped, items: params[:per_page] || 10)
  end

  def show
    @device = Device.find(params[:id])
    render layout: false
  end

  def new
    @device = Device.new
    @products = Product.where(category: 154121870)
  end

  def create
    @device = Device.new(device_params)

    if @device.save
      redirect_to devices_path, notice: "Device creado"
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace( "modal", template: "devices/new", layout: false, locals: { device: @device }), status: :unprocessable_entity
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