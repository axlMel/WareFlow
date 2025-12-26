class ApplicationFinder
  def initialize(relation, params = {})
    @relation = relation
    @params = params
  end

  def call
    raise NotImplementedError, "Debes implementar el método `call` en tu finder."
  end
end
