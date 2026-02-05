module Exports
  class BaseExporter
    attr_reader :records

    def initialize(records)
      @records = records
    end

    def export
      raise NotImplementedError
    end
  end
end
