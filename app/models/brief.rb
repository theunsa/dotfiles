class Brief < ApplicationRecord
  belongs_to :account
  has_many :documents, -> { order(:position) }, dependent: :destroy
  has_many :visits, dependent: :destroy

  accepts_nested_attributes_for :documents

  # How the client is asked to reply. "none" hides the CTA entirely; the other
  # three read cta_value as a number or an address, and cta_text as the prefill
  # (WhatsApp message body, email subject — a phone call has nothing to prefill).
  CTA_KINDS = %w[none whatsapp email phone].freeze
  CTA_LABELS = { "whatsapp" => "WhatsApp me", "email" => "Email me", "phone" => "Call me" }.freeze
  DEFAULT_CTA_TEXT = "Hi, I read the proposal — let's talk about Step 1".freeze
  E164 = /\A\+[1-9]\d{6,14}\z/

  # Optional passcode: blank means the brief is open to anyone with the link.
  has_secure_password :passcode, validations: false

  validates :client_name, presence: true
  # Globally unique, not per-account: /b/:slug is one shared URL space, so that
  # a client only ever needs the link, never the tenant it belongs to.
  validates :slug, presence: true, uniqueness: true
  validates :cta_kind, inclusion: { in: CTA_KINDS }
  validate :cta_value_suits_kind

  before_validation :generate_slug, on: :create

  scope :published, -> { where(published: true) }

  def passcode_protected? = passcode_digest.present?

  def primary_document = documents.first

  def to_param = slug

  def cta? = cta_kind != "none" && cta_value.present?

  def cta_label = CTA_LABELS[cta_kind]

  def cta_url
    return nil unless cta?
    case cta_kind
    when "whatsapp" then "https://wa.me/#{cta_value.delete('+')}?text=#{ERB::Util.url_encode(cta_text.presence || DEFAULT_CTA_TEXT)}"
    when "email"    then "mailto:#{cta_value}?subject=#{ERB::Util.url_encode(cta_text.presence || DEFAULT_CTA_TEXT)}"
    when "phone"    then "tel:#{cta_value}"
    end
  end

  def last_viewed_at = visits.maximum(:viewed_at)

  private

  # Blank is always allowed — it just means the CTA is not set up yet.
  def cta_value_suits_kind
    return if cta_value.blank?
    case cta_kind
    when "whatsapp", "phone"
      errors.add(:cta_value, "needs the country code, like +27821234567") unless cta_value.match?(E164)
    when "email"
      errors.add(:cta_value, "must be an email address") unless cta_value.match?(URI::MailTo::EMAIL_REGEXP)
    end
  end

  # Unguessable-slug security model: 4 random base36 chars + readable client name.
  def generate_slug
    return if slug.present?
    return if client_name.blank?
    self.slug = "#{SecureRandom.alphanumeric(4).downcase}-#{client_name.parameterize}"
  end
end
