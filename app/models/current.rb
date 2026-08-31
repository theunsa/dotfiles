class Current < ActiveSupport::CurrentAttributes
  attribute :session
  # Set two ways: from the signed-in user (admin), or from the dossier being
  # viewed (public pages, which have no session). See Authentication and
  # DossierScoped.
  attribute :account
  delegate :user, to: :session, allow_nil: true
end
