class AcceptancesController < ApplicationController
  include DossierScoped

  before_action :require_unlocked
  before_action :require_published
  rate_limit to: 10, within: 1.minute, only: :create

  def create
    # Idempotent per label, so a double-tap records once but a second accept block
    # block (a later step) can still be accepted on its own.
    label = params[:label].presence || "Accepted"
    @dossier.acceptances.create!(label: label) unless @dossier.accepted?(label)
    redirect_to dossier_path(slug: @dossier.slug)
  end

  private

  # The author can now preview a draft, which means they can reach its accept
  # button. An acceptance is a record of what the *client* agreed to, so a
  # draft must never be able to produce one.
  def require_published
    return if @dossier.published?

    redirect_to dossier_path(slug: @dossier.slug),
                alert: "This dossier is still a draft — publish it before it can be accepted."
  end
end
