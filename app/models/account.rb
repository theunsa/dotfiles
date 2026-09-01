# A tenant: one customer of this app, with their own users and briefs.
#
# Tenancy is row-based — every account lives in the same SQLite database and is
# separated by account_id, not by a database file per customer. See
# docs/PLAN.md for why.
class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :briefs, dependent: :destroy

  normalizes :contact_email, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/,
                             message: "may contain only lowercase letters, numbers and dashes" }

  before_validation :generate_slug, on: :create

  def to_param = slug

  # What the brand bar and the unlock page show. Falls back to the app-wide
  # defaults so an account that has not filled these in still renders.
  def brand
    defaults = Rails.application.config.x.brand
    {
      name: name,
      tagline: tagline.presence || defaults[:tagline],
      contact: contact_email.presence || defaults[:contact]
    }
  end

  private

  def generate_slug
    return if slug.present? || name.blank?
    self.slug = name.parameterize
  end
end
