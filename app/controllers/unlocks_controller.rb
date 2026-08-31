class UnlocksController < ApplicationController
  include DossierScoped

  rate_limit to: 10, within: 1.minute, only: :create

  def new
    redirect_to dossier_path(slug: @dossier.slug) unless @dossier.passcode_protected?
  end

  def create
    if @dossier.authenticate_passcode(params[:passcode].to_s)
      unlock!
      redirect_to dossier_path(slug: @dossier.slug)
    else
      redirect_to dossier_unlock_path(slug: @dossier.slug), alert: "That passcode is not right."
    end
  end
end
