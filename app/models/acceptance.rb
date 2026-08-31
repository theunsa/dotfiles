class Acceptance < ApplicationRecord
  belongs_to :dossier

  validates :label, presence: true

  before_validation { self.accepted_at ||= Time.current }
end
