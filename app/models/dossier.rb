class Dossier < ApplicationRecord
  belongs_to :account
  has_many :documents, -> { order(:position) }, dependent: :destroy
  has_many :visits, dependent: :destroy
  has_many :acceptances, dependent: :destroy

  accepts_nested_attributes_for :documents

  # Optional passcode: blank means the dossier is open to anyone with the link.
  has_secure_password :passcode, validations: false

  validates :client_name, presence: true
  # Globally unique, not per-account: /d/:slug is one shared URL space, so that
  # a client only ever needs the link, never the tenant it belongs to.
  validates :slug, presence: true, uniqueness: true
  validates :whatsapp_number, format: { with: /\A\+[1-9]\d{6,14}\z/, message: "must be E.164, e.g. +27821234567" },
                              allow_blank: true

  before_validation :generate_slug, on: :create

  scope :published, -> { where(published: true) }

  def passcode_protected? = passcode_digest.present?

  def primary_document = documents.first

  def to_param = slug

  def whatsapp_url
    return nil if whatsapp_number.blank?
    text = whatsapp_text.presence || "Hi, I read the proposal — let's talk about Step 1"
    "https://wa.me/#{whatsapp_number.delete('+')}?text=#{ERB::Util.url_encode(text)}"
  end

  def last_viewed_at = visits.maximum(:viewed_at)

  # No label: "anything accepted at all?" (admin list). With one: that step only.
  def accepted?(label = nil) = label ? acceptances.exists?(label: label) : acceptances.exists?

  private

  # Unguessable-slug security model: 4 random base36 chars + readable client name.
  def generate_slug
    return if slug.present?
    return if client_name.blank?
    self.slug = "#{SecureRandom.alphanumeric(4).downcase}-#{client_name.parameterize}"
  end
end
