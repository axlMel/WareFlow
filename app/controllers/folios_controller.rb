class FoliosController < ApplicationController
  before_action :set_folio, only: [:show, :edit, :update, :destroy]

  def index
    finder = FindFolios.new(Folio.all, params)
    scoped = finder.call

    sort_column = params[:sort] || 'folios.created_at'
    sort_direction = params[:direction] == 'asc' ? 'asc' : 'desc'
    scoped = scoped.reorder("#{sort_column} #{sort_direction}")

    per_page = params[:per_page].presence&.to_i || 10
    @pagy, @folios = pagy(scoped, items: per_page, limit: per_page)
  end

  def create
    @folio = Folio.new(folio_params)
    @folio.status = :crafted
    if @folio.save
      redirect_to folios_path(show: @folio.id), notice: "Folio creado correctamente.", status: :see_other
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace( "modal", template: "folios/new", layout: false, locals: { folio: @folio }), status: :unprocessable_entity
        end

        format.html do
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    if @folio.update(folio_params)
      redirect_to folios_path(show: @folio.id), notice: "Folio actualizado correctamente.", status: :see_other
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("modal", template: "folios/edit", layout: false, locals: {folio: @folio.id }), status: :unprocessable_entity
        end

        format.html do
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  def show
    @folio = Folio.find(params[:id])
    render layout: false
  end

  def new
    @folio = Folio.new
    render layout: false
  end

  def edit
    @users = User.where(admin: false)
    render layout: false
  end

  def destroy
    if @folio.destroy
      redirect_to folios_path, notice: "Folio eliminado exitosamente.", status: :see_other
    else
      redirect_to folios_path, alert: @folio.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def import
    if request.get?
      render partial: "shared/import", locals: { import_url: import_folios_path, download_url: download_base_folios_path, manual_url: manual_folios_path }
      return
    end

    file = params[:file]
    redirect_to folios_path, alert: "Archivo requerido" and return unless file

    Imports::FoliosImporter.new(file).import!

    redirect_to folios_path, notice: "Importación exitosa"
  rescue => e
    redirect_to folios_path, alert: e.message
  end

  def manual
    @rows = [Imports::Folios::Builder.empty_row]
    @folio = Folio.new
    render :preview
  end

  def download_base
    send_file Rails.root.join("public/templates/foliosImport_base.xlsx"),
              filename: "foliosImport_base.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
              disposition: "attachment"
  end

  def export
    render partial: "shared/export", locals: { export_url: download_folios_path }
  end

  def download
    scope = if params[:scope] == "filtered"
      FindFolios.new(Folio.all, params).call.unscope(:limit, :offset)
    else
      Folio.all
    end

    export_params = { exported_by: Current.user.username,
      filters: params.permit(:q, :status, :from, :to, :scope, :export_format).to_h
    }


    exporter =
      case params[:export_format]
      when "xlsx"
        Exports::Folios::ExcelExporter.new(scope, export_params)
      when "pdf"
        Exports::Folios::PdfExporter.new(scope, export_params)
      else
        raise "Formato no soportado"
      end

    file = exporter.export

    if params[:export_format] == "xlsx"
      send_data file.to_stream.read, filename: "folios.xlsx", disposition: "attachment"
    else
      send_data file.render, filename: "folios.pdf", type: "application/pdf", disposition: "attachment"
    end
  end


  private

  def set_folio
    @folio = Folio.find(params[:id])
  end

  def folio_params
    params.require(:folio).permit(:client, :user_id, :status, :service, :accessories)
  end
end
