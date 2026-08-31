class AcceptancesController < ApplicationController
  include DossierScoped

  before_action :require_unlocked
  rate_limit to: 10, within: 1.minute, only: :create

  def create
    @dossier.acceptances.create!(label: params[:label].presence || "Accepted") unless @dossier.accepted?
    redirect_to dossier_path(slug: @dossier.slug)
  end
end
