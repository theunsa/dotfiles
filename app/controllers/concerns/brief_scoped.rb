# Shared by the public brief-facing controllers: slug lookup, passcode gate.
module BriefScoped
  extend ActiveSupport::Concern

  included do
    allow_unauthenticated_access
    before_action :set_brief
    helper_method :previewing_draft?
  end

  private

  # Looked up across all accounts on purpose: the slug is the whole security
  # model and is globally unique, so a client needs only the link. The brief
  # then decides which tenant's brand the page wears.
  #
  # Drafts 404 for the world but stay visible to their own author, so a brief
  # can be checked on its real page before it goes live. Being signed in to some
  # other account is not enough — same reasoning as require_unlocked below.
  def set_brief
    @brief = Brief.find_by!(slug: params[:slug])
    Current.account = @brief.account
    raise ActiveRecord::RecordNotFound unless @brief.published? || author?
  end

  # The signed-in user owns this brief's account.
  def author? = authenticated? && Current.user.account_id == @brief.account_id

  def previewing_draft? = !@brief.published?

  # The brief's own author bypasses the gate so they can always view their
  # own pages. Being signed in to some other account is not enough.
  def require_unlocked
    return unless @brief.passcode_protected?
    return if author? || unlocked?

    redirect_to brief_unlock_path(slug: @brief.slug)
  end

  def unlocked? = Array(session[:unlocked_briefs]).include?(@brief.id)

  def unlock!
    session[:unlocked_briefs] = Array(session[:unlocked_briefs]) | [ @brief.id ]
  end
end
