class Products::InstallationGuidesController < ApplicationController
  def show
    guides = YAML.load_file(Rails.root.join("config/installation_guides.yml")).with_indifferent_access
    data = guides[params[:id]]

    if data.nil?
      render plain: "Sin guía disponible", status: :not_found
    else
      render partial: "supports/installation_guide", locals: { diagram: data[:diagrama], commands: data[:comandos] }
    end
  end
end