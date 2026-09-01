class Document < ApplicationRecord
  belongs_to :brief

  validates :title, presence: true
  validates :body_markdown, presence: true

  before_validation :set_defaults, on: :create

  def body_html
    MarkdownRenderer.new(body_markdown).to_html
  end

  private

  def set_defaults
    self.position ||= (brief&.documents&.maximum(:position) || 0) + 1
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end
end
