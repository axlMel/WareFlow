class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include Language
  include Pagy::Backend
  include Error
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end