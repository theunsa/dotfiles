# Every admin controller reaches its records through here, so a query that
# forgets the tenant is a NoMethodError rather than another account's data.
class Admin::BaseController < ApplicationController
  private

  def dossiers = current_account.dossiers
end
