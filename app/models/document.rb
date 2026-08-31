class Document < ApplicationRecord
  belongs_to :dossier

  validates :title, presence: true
  validates :body_markdown, presence: true

  before_validation :set_defaults, on: :create

  # Pass the calling template's view context (`self` in ERB) so block partials
  # render inside the real request — the accept block builds a form and needs the CSRF
  # token that only a request-bound view emits.
  def body_html(view = nil)
    MarkdownRenderer.new(body_markdown, context: { dossier: dossier }).to_html(view)
  end

  private

  def set_defaults
    self.position ||= (dossier&.documents&.maximum(:position) || 0) + 1
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end
end
