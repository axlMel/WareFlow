class FoliosController < ApplicationController
  before_action :set_folio, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.where(admin: false)
    if params[:q].present?
      query = params[:q]
      @folios = Folio.joins(:user).where(
        "folios.id::text ILIKE :q OR folios.client ILIKE :q OR users.username ILIKE :q",
        q: "%#{query}%"
      ).includes(:user).limit(10)

      render json: @folios.map { |f| { id: f.id, client: f.client, user_username: f.user.username } }
    else
      @folios = Folio.includes(:user).order(created_at: :desc)

      respond_to do |format|
        format.html # <- esto es necesario
        format.turbo_stream # <- y esto también
      end
    end
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
      #redirect_to folio_path(@folio), notice: "Folio creado correctamente."
      respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("modal", partial: "shared/modal", locals: { content: render_to_string("folios/new", locals: { folio: @folio }) })
      end
      format.html # fallback
    end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @folio.update(folio_params)
      redirect_to folio_path(@folio), notice: "Folio actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
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
    if @folio.assignments.exists?
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "No puedes eliminar este folio porque ya tiene productos asignados. Contacta al Coordinador de Servicios para realizar la devolución."
          render turbo_stream: turbo_stream.update("flash", partial: "shared/flash")
        end
        format.html do
          redirect_to folios_path, alert: "No puedes eliminar este folio porque ya tiene productos asignados. Contacta al Coordinador de Servicios."
        end
      end
      return
    end

    @folio.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("folio_#{@folio.id}")
      end
      format.html { redirect_to folios_path, notice: "Folio eliminado correctamente." }
    end
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
    params.require(:folio).permit(:client, :user_id, :status, :service, :accessories, :folio_id)
  end
end
