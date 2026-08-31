# Shared by the public dossier-facing controllers: slug lookup, passcode gate.
module DossierScoped
  extend ActiveSupport::Concern

  included do
    allow_unauthenticated_access
    before_action :set_dossier
    helper_method :previewing_draft?
  end

  private

  # Looked up across all accounts on purpose: the slug is the whole security
  # model and is globally unique, so a client needs only the link. The dossier
  # then decides which tenant's brand the page wears.
  #
  # Drafts 404 for the world but stay visible to their own author, so a dossier
  # can be checked on its real page before it goes live. Being signed in to some
  # other account is not enough — same reasoning as require_unlocked below.
  def set_dossier
    @dossier = Dossier.find_by!(slug: params[:slug])
    Current.account = @dossier.account
    raise ActiveRecord::RecordNotFound unless @dossier.published? || author?
  end

  # The signed-in user owns this dossier's account.
  def author? = authenticated? && Current.user.account_id == @dossier.account_id

  def previewing_draft? = !@dossier.published?

  # The dossier's own author bypasses the gate so they can always view their
  # own pages. Being signed in to some other account is not enough.
  def require_unlocked
    return unless @dossier.passcode_protected?
    return if author? || unlocked?

    redirect_to dossier_unlock_path(slug: @dossier.slug)
  end

  def unlocked? = Array(session[:unlocked_dossiers]).include?(@dossier.id)

  def unlock!
    session[:unlocked_dossiers] = Array(session[:unlocked_dossiers]) | [ @dossier.id ]
  end
end
