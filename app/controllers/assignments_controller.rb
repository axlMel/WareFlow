class AssignmentsController < ApplicationController
  before_action :set_assignment, only: %i[show edit update destroy]

  def index
    finder = FindAssignments.new(Assignment.all, params)
    assignments = finder.call
    @pagy, @assignments = pagy(finder.call)
  end

  def show; end

  def new
    @assignment = Assignment.new
    load_dependencies
  end

  def edit
    @assignment = Assignment.find(params[:id])
    load_dependencies
  end

  def create
    @assignment = Assignment.new(assignment_params)

    if @assignment.save
      redirect_to @assignment, notice: "Asignación creada con éxito."
    else
      load_dependencies
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @assignment = Assignment.find(params[:id])
    if @assignment.update(assignment_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "assignment_edit_#{@assignment.id}",
            partial: "assignments/edit_success", # puedes poner un parcial vacío
            locals: { assignment: @assignment }
          )
        end
        format.html { redirect_to @assignment, notice: "Asignación actualizada." }
      end
    else
      load_dependencies
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @assignment.destroy
    redirect_to assignments_path, notice: "Asignación eliminada."
  end

  private

  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  def assignment_params
    params.require(:assignment).permit(:delivery_id, :product_id, :quantity, :status, :user_id)
  end

  def load_dependencies
    @products = Product.all
    @deliveries = Delivery.all
  end
end