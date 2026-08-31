# Shared by the public dossier-facing controllers: slug lookup, passcode gate.
module DossierScoped
  extend ActiveSupport::Concern

  included do
    allow_unauthenticated_access
    before_action :set_dossier
    helper_method :previewing_draft?
  end

  private

  # Drafts 404 for the world but stay visible to the signed-in author, so a
  # dossier can be checked on its real page before it goes live. Same reasoning
  # as require_unlocked below: the author can always see their own pages.
  def set_dossier
    scope = authenticated? ? Dossier.all : Dossier.published
    @dossier = scope.find_by!(slug: params[:slug])
  end

  def previewing_draft? = !@dossier.published?

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
