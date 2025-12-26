module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
    before_action :protect_pages

    private

    def set_current_user
      Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
    end
    #un cambio realizado para redirigir a los usuarios deslogeados a new_session_path
    def protect_pages
      return if Current.user

      respond_to do |format|
        format.html {
          response.set_header("Turbo-Visit-Control", "replace")
          redirect_to new_session_path, alert: t('common.not_logged_in'), status: :see_other
        }
        format.turbo_stream {
          # Fuerza redirección total, si entra un turbo stream sin usuario
          redirect_to new_session_path, status: :see_other
        }
      end
    end
  end
end
