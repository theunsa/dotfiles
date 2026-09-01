# Rewrites the Nuxt prototype's MDC directive blocks into the fenced YAML
# blocks MarkdownRenderer reads:
#
#   ::callout{title="Heads up"}        ```callout
#   Some **markdown** body.       →    title: Heads up
#   ::                                 body: Some **markdown** body.
#                                      ```
#
# Attributes and front matter merge into one YAML hash; free text after the
# front matter becomes the block's `body:` key.
#
# Used by `rake brief:import` for prototype files and by the data migration
# that converted the documents written before the syntax changed. Text with no
# directives passes through untouched, so running it twice is harmless.
class LegacyBlockConverter
  DIRECTIVE = /\A::(?<name>[a-z][a-z0-9-]*)(?:\{(?<attrs>[^}]*)\})?\s*\z/
  CLOSING = "::".freeze
  YAML_CLASSES = [ Date, Time, DateTime ].freeze

  def self.call(markdown) = new(markdown).to_markdown

  def initialize(markdown)
    @lines = markdown.to_s.lines
  end

  def to_markdown
    out = []
    i = 0
    while i < @lines.length
      match = @lines[i].chomp.match(DIRECTIVE)
      closing = match && find_closing(i)

      if closing
        out << fence(match, @lines[(i + 1)...closing])
        i = closing + 1
      else
        out << @lines[i]
        i += 1
      end
    end
    out.join
  end

  private

  def find_closing(start)
    ((start + 1)...@lines.length).find { |j| @lines[j].chomp.strip == CLOSING }
  end

  def fence(match, body_lines)
    data = parse_attrs(match[:attrs])
    front_matter, body = split_front_matter(body_lines)
    data.merge!(front_matter)
    text = body.join.strip
    data["body"] = text if text.present?

    "```#{match[:name]}\n#{YAML.dump(data).delete_prefix("---\n")}```\n"
  end

  # {title="Foo" icon="i-lucide-shield-check"} → { "title" => "Foo", ... }
  def parse_attrs(attrs)
    attrs.to_s.scan(/([a-z][a-z0-9-]*)="([^"]*)"/).to_h
  end

  # Inside a directive, an optional YAML section was delimited by `---` … `---`.
  def split_front_matter(body_lines)
    return [ {}, body_lines ] unless body_lines.first&.chomp&.strip == "---"

    closing = (1...body_lines.length).find { |j| body_lines[j].chomp.strip == "---" }
    return [ {}, body_lines ] unless closing

    data = YAML.safe_load(body_lines[1...closing].join, permitted_classes: YAML_CLASSES)
    [ data.is_a?(Hash) ? data : {}, body_lines[(closing + 1)..] ]
  rescue Psych::Exception
    # An unreadable block is left exactly as written rather than half-converted,
    # so the author still has the original text to fix by hand.
    [ {}, body_lines ]
  end
end
