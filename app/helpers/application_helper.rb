module ApplicationHelper
  # The brand on show: the current tenant's, or the app's own on pages that
  # belong to no tenant (the landing page, the sign-in screen).
  def brand = Current.account&.brand || Rails.application.config.x.brand
end
