# Shared by the public dossier-facing controllers: slug lookup, passcode gate.
module DossierScoped
  extend ActiveSupport::Concern

  included do
    allow_unauthenticated_access
    before_action :set_dossier
  end

  private

  def set_dossier
    @dossier = Dossier.published.find_by!(slug: params[:slug])
  end

  # Admin sessions bypass the gate so the author can always view their own pages.
  def require_unlocked
    return unless @dossier.passcode_protected?
    return if authenticated? || unlocked?

    redirect_to dossier_unlock_path(slug: @dossier.slug)
  end

  def unlocked? = Array(session[:unlocked_dossiers]).include?(@dossier.id)

  def unlock!
    session[:unlocked_dossiers] = Array(session[:unlocked_dossiers]) | [ @dossier.id ]
  end
end
