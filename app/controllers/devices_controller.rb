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
    @sim_history = @device.device_sim_histories.includes(:sim).order(installed_at: :desc)
    @available_sims = Sim.available
    @active_history = @sim_history.detect { |history| history.removed_at.nil? }
    @active_sim = @active_history&.sim
    @movements = @device.device_movements.order(performed_at: :desc)
  end

  def new
    @device = Device.new
    @products = Product.where(category: 154121870)
  end

  def swap_sim
    device = Device.find(params[:id])
    sim = Sim.find_by(id: params[:sim_id])
    reason = params[:reason]

    case params[:action_type]
    when "assign"
      device.install_sim!(sim, reason: reason.presence || "Asignación manual de SIM")
      notice = "SIM asignada correctamente."

    when "replace"
      device.replace_sim!(sim, reason: reason)
      notice = "SIM reemplazada correctamente."

    when "remove"
      device.remove_sim!(reason: reason)
      notice = "SIM removida correctamente."

    when "warranty"
      device.send_to_warranty!(reason: reason)
      notice = "Dispositivo enviado a garantía."

    when "damaged"
      device.mark_as_damaged!(reason: reason)
      notice = "Dispositivo marcado como dañado."

    when "returned"
      device.mark_as_returned!(reason: reason)
      notice = "Dispositivo devuelto al proveedor."

    else
      redirect_to device_path(device), alert: "Movimiento no válido."
      return
    end

    redirect_to device_path(device), notice: notice
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to device_path(device), alert: e.message
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
    @products = Product.where(category: 154121870)
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