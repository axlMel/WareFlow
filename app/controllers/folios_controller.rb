class FoliosController < ApplicationController
  before_action :set_folio, only: [:show, :edit, :update, :destroy]

  def index
    finder = FindFolios.new(Folio.all, params)
    scoped = finder.call

    sort_column = params[:sort] || 'folios.created_at'
    sort_direction = params[:direction] == 'desc' ? 'desc' : 'asc'
    scoped = scoped.unscope(:limit, :offset)

    # Me aseguro que per_page sea un int no char
    per_page = params[:per_page].presence&.to_i || 10
    @pagy, @folios = pagy(scoped, items: per_page, limit: per_page)
  end

  def assignment_products
    @folio = Folio.find(params[:id])
    @assignments = @folio.assignments.includes(:product).where(status: :pending)
    @assignments_by_category = @assignments.group_by { |a| a.product.category }
    @user_stock_products = Product.with_positive_available_stock_for(Current.user)
    @replacements = @user_stock_products.group_by(&:category_id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "assignmentsContainer",
          partial: "supports/assignment_products",
          locals: {
            assignments_by_category: @assignments_by_category,
            user_stock_products: @user_stock_products,
            replacements: @replacements
          }
        )
      end
    end
  end

  def create
    @folio = Folio.new(folio_params)
    @folio.crafted!
    if @folio.save
      redirect_to folios_path(show: @folio.id), notice: "Folio creado correctamente.", status: :see_other
    else
      flash.now[:alert] = "No se pudo crear el folio"
      render :new, status: :unprocessable_entity, layout: false
    end
  end

  def update
    if @folio.update(folio_params)
      redirect_to folios_path(show: @folio.id), notice: "Folio actualizado correctamente.", status: :see_other
    else
      redirect_to folios_path, alert: @folio.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def details
    @folio = Folio.find(params[:id])
    @assignments = @folio.assignments.includes(:products)

    render turbo_stream: [
      turbo_stream.update("client", @folio.client),
      turbo_stream.update("user_id", @folio.user.username),
      turbo_stream.update("id", @folio.id),
      turbo_stream.update("folio-selector-products", partial: "supports/products", locals: { assignments: @assignments, user_stock_products: current_user.products })
    ]
  end

  def show
    @folio = Folio.find(params[:id])
    render layout: false
  end

  def new
    @folio = Folio.new
    @support = Support.new
    @users = User.where(admin: false)
    @assignments = [] # o puedes dejarlo nil si aún no hay folio seleccionado

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("modal", partial: "shared/modal", locals: { content: render_to_string("folios/form", locals: { folio: @folio }) })
      end
      format.html # fallback
    end
  end

  def edit
    @users = User.where(admin: false)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("modal", partial: "shared/modal", locals: { content: render_to_string("folios/form", locals: { folio: @folio }) })
      end
      format.html
    end
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
      render partial: "shared/import"
      return
    end

    file = params[:file]
    redirect_to folios_path, alert: "Archivo requerido" and return unless file

    Imports::FoliosImporter.new(file).import!

    redirect_to folios_path, notice: "Importación exitosa"
  rescue => e
    redirect_to folios_path, alert: e.message
  end

  def download_base
    send_file Rails.root.join("public/templates/foliosImport_base.xlsx"),
              filename: "foliosImport_base.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
              disposition: "attachment"
  end


  private

  def support_info
    @folio = Folio.find(params[:id])
    @assignments = @folio.assignments.includes(:product, :user)
    render partial: "supports/folio_info", locals: { folio: @folio, assignments: @assignments }
  end

  def set_folio
    @folio = Folio.find(params[:id])
  end

  def folio_params
    params.require(:folio).permit(:client, :user_id, :status, :service, :accessories)
  end
end
