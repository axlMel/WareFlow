class ProductPolicy < BasePolicy
  def edit
    true
  end

  def update
    true
  end

  def destroy
    true
  end
end
