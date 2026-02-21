module Exports
  class BaseExporter
    attr_reader :records

    def initialize(records, params={})
      @records = records
      @params = params
    end

    def export
      raise NotImplementedError
    end

    private

    def base_metadata
      [
        ["Generado el", Time.current.strftime("%d/%m/%Y %H:%M")],
        ["Extraído por", @params[:exported_by] || "-"]
      ]
    end

    def filter_metadata
      return [] if @params[:filters].blank?

      @params[:filters].to_h.reject { |_k, v| v.blank? }.map do |k, v|
        [ I18n.t("exports.filters.#{k}", default: k.to_s.humanize), 
          I18n.t("exports.values.#{v}", default: v.to_s.humanize)
        ]
      end
    end
  end
end