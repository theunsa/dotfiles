class UnlocksController < ApplicationController
  include BriefScoped

  rate_limit to: 10, within: 1.minute, only: :create

  def new
    redirect_to brief_path(slug: @brief.slug) unless @brief.passcode_protected?
  end

  def create
    if @brief.authenticate_passcode(params[:passcode].to_s)
      unlock!
      redirect_to brief_path(slug: @brief.slug)
    else
      redirect_to brief_unlock_path(slug: @brief.slug), alert: "That passcode is not right."
    end
  end
end
