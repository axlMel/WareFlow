class AssignmentsController < ApplicationController
  before_action :set_assignment, only: %i[show edit update destroy]

  def index
    finder = FindAssignments.new(Assignment.all, params)
    @pagy, @assignments = pagy(finder.call)
  end

  def show;
    render layout: false
  end

  def new
    @assignment = Assignment.new
    load_dependencies
    render layout: false
  end

  def edit
    @assignment = Assignment.find(params[:id])
    load_dependencies
    render layout: false
  end

  def create
    @assignment = Assignment.new(assignment_params)
    @assignment.status = :assigned

    if @assignment.save
      redirect_to assignments_path(show: @assignment.id), notice: "Asignación creada correctamente", status: :see_other
    else
      load_dependencies
      render :new, status: :unprocessable_entity, layout: false
    end
  end

  def update
    if @assignment.update(assignment_params)
      redirect_to assignments_path(show: @assignment.id), notice: "Asignación actualizada correctamente", status: :see_other
    else
      load_dependencies
      render :edit, status: :unprocessable_entity, layout: false
    end
  end


  def destroy
    @assignment.destroy
    redirect_to assignments_path, notice: "Asignacion eliminada correctamente", status: :see_other
  end

  private

  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  def assignment_params
    params.require(:assignment).permit(:delivery_id, :product_id, :quantity, :status, :user_id)
  end

  def load_dependencies
    @products = Product.all.order(:title)
    @deliveries = Delivery.all
    @users = User.where(admin: false).order(:username)
  end
end