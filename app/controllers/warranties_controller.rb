class WarrantiesController < ApplicationController
  before_action :set_warranty, only: [:show, :edit, :update, :destroy]

  def index
    finder = FindWarranties.new(Warranty.all, params)
    scoped = finder.call

    sort_column = params[:sort] || 'warranties.created_at'
    sort_direction = params[:direction] == 'asc' ? 'asc' : 'desc'
    scoped = scoped.reorder("#{sort_column} #{sort_direction}")
    
    per_page = params[:per_page].presence&.to_i || 10
    @pagy, @warranties = pagy(scoped, items: per_page, limit: per_page)
  end

  def show
    render layout: false
  end

  def new
    @warranty = Warranty.new
    load_dependencies
  end

  def create
    @warranty = Warranty.new(warranty_params)
    @warranty.state = :pending
    if @warranty.save
      redirect_to warranties_path(show: @warranty.id), notice: "Garantía creada exitosamente.", status: :see_other
    else
      load_dependencies
      
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            template: "warranties/new",
            layout: false,
            locals: { warranty: @warranty }
          ), status: :unprocessable_entity
        end
        format.html do
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @warranty = Warranty.find(params[:id])
    load_dependencies
    render layout: false
  end

  def update
    if @warranty.update(warranty_params)
      redirect_to warranties_path(show: @warranty.id), notice: "Garantía actualizada exitosamente.", status: :see_other
    else
      load_dependencies
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            template: "warranties/new",
            layout: false,
            locals: { warranty: @warranty }
          ), status: :unprocessable_entity
        end
        format.html do
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    if @warranty.destroy
      redirect_to warranties_path, notice: "Garantía eliminada exitosamente.", status: :see_other
    else
      redirect_to warranties_path, alert: @warranty.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def import
    if request.get?
      render partial: "shared/import", locals: { import_url: import_warranties_path, download_url: download_base_warranties_path, manual_url: manual_warranties_path }
      return
    end

    file = params[:file]
    redirect_to warranties_path, alert: "Archivo requerido" and return unless file
    parser = Imports::Warranties::Parser.new(file)
    @rows = parser.parse
    @warranty = Warranty.new

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          template: "warranties/preview",
          layout: false
        )
      end
      format.html do
        render :index, status: :unprocessable_entity
      end
    end
  end

  def manual
    @rows = [Imports::Warranties::Builder.empty_row]
    @warranty = Warranty.new
    render :preview
  end

  def confirm_import
    rows = (params[:rows] || {}).to_unsafe_h.values
    persister = Imports::Warranties::Persister.new(rows)

    if persister.persist
      redirect_to warranties_path, notice: "Importación exitosa"
    else
      @rows = rows
      @warranty = Warranty.new

      persister.errors.each do |index, model_errors|
        model_errors.full_messages.each do |message|
          @warranty.errors.add(:base, "Fila #{index + 1}: #{message}")
        end
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace( "modal", template: "warranties/preview", layout: false ), status: :unprocessable_entity
        end
        format.html do
          render :preview, status: :unprocessable_entity
        end
      end
    end
  end


  def download_base
    send_file Rails.root.join("public/templates/warrantiesImport_base.xlsx"), filename: "warrantiesImport_base.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", disposition: "attachment"
  end

  def export
    render partial: "shared/export", locals: { export_url: download_warranties_path}
  end

  def download
    scope = if params[:scope] == "filtered"
      FindWarranties.new(Warranty.all, params).call.unscope(:limit, :offset)
    else
      Warranty.all
    end

    export_params = { exported_by: Current.user.username, filters: params.permit(:q, :status, :from, :to, :scope, :export_format).to_h }

    exporter = case params[:export_format]
    when "xlsx"
      Exports::Warranties::ExcelExporter.new(scope, export_params)
    when "pdf"
      Exports::Warranties::PdfExporter.new(scope, export_params)
    else
      raise "Formato no soportado"
    end

    file = exporter.export
    if params[:export_format] == "xlsx"
      send_data file.to_stream.read, filename: "garantias.xlsx", disposition: "attachment"
    else
      send_data file.render, filename: "garantias.pdf", type: "application/pdf", disposition: "attachment"
    end
  end

  private

  def set_warranty
    @warranty = Warranty.find(params[:id])
  end

  def warranty_params
    params.require(:warranty).permit(:client, :user_id, :state, :commit, :product_id)
  end

  def load_dependencies
    @products = Product.all.order(:title)
    @users = User.all.order(:username)
  end
end
