# Renders dossier markdown: GFM via Commonmarker, plus the prototype's MDC-style
# blocks (::steps / ::callout / ::faq / ::accept) mapped to partials in
# app/views/markdown/. The `::name … ::` syntax is kept exactly as in
# nuxt-prototype/ so existing content pastes in unchanged.
class MarkdownRenderer
  BLOCK_START = /\A::(?<name>[a-z][a-z0-9-]*)(?:\{(?<attrs>[^}]*)\})?\s*\z/
  BLOCK_END   = /\A::\s*\z/
  KNOWN_BLOCKS = %w[steps callout faq accept].freeze

  # context: extra locals handed to block partials (e.g. dossier: for ::accept).
  def initialize(source, context: {})
    @source = source.to_s
    @context = context
  end

  def to_html
    segments.map do |seg|
      seg[:type] == :markdown ? markdown_to_html(seg[:text]) : block_to_html(seg)
    end.join("\n").html_safe
  end

  def accept_block? = segments.any? { |s| s[:type] == :block && s[:name] == "accept" }

  # Helper for partials that carry nested markdown (FAQ answers, step bodies).
  def inline_html(text)
    markdown_to_html(text.to_s).html_safe
  end

  private

  def segments
    @segments ||= parse
  end

  def parse
    result = []
    buffer = []
    lines = @source.lines
    i = 0
    while i < lines.length
      line = lines[i]
      if (match = line.chomp.match(BLOCK_START))
        block_lines = []
        j = i + 1
        j += 1 while j < lines.length && !lines[j].chomp.match?(BLOCK_END)
        if j < lines.length
          block_lines = lines[(i + 1)...j]
          result << { type: :markdown, text: buffer.join } if buffer.any?
          buffer = []
          result << build_block(match, block_lines)
          i = j + 1
          next
        end
        # No closing "::" — treat the line as plain text.
      end
      buffer << line
      i += 1
    end
    result << { type: :markdown, text: buffer.join } if buffer.any?
    result
  end

  def build_block(match, block_lines)
    data, body = split_front_matter(block_lines)
    {
      type: :block,
      name: match[:name],
      attrs: parse_attrs(match[:attrs]),
      data: data,
      body: body
    }
  end

  # Inside a block, an optional YAML section is delimited by `---` … `---`.
  def split_front_matter(block_lines)
    stripped = block_lines.drop_while { |l| l.strip.empty? }
    return [ {}, block_lines.join ] unless stripped.first&.chomp&.strip == "---"

    closing = stripped[1..].index { |l| l.chomp.strip == "---" }
    return [ {}, block_lines.join ] unless closing

    yaml = stripped[1..closing].join
    body = stripped[(closing + 2)..].to_a.join
    [ YAML.safe_load(yaml) || {}, body ]
  rescue Psych::Exception
    [ {}, block_lines.join ]
  end

  # {title="Foo" icon="i-lucide-shield-check"} → { "title" => "Foo", ... }
  def parse_attrs(attrs)
    attrs.to_s.scan(/([a-z][a-z0-9-]*)="([^"]*)"/).to_h
  end

  def markdown_to_html(text)
    return "" if text.strip.empty?
    Commonmarker.to_html(text, options: { render: { unsafe: false }, extension: { header_ids: nil } })
  end

  def block_to_html(seg)
    partial = KNOWN_BLOCKS.include?(seg[:name]) ? seg[:name] : "unknown"
    ApplicationController.render(
      partial: "markdown/#{partial}",
      locals: {
        name: seg[:name],
        attrs: seg[:attrs],
        data: seg[:data],
        body_html: markdown_to_html(seg[:body]).html_safe,
        renderer: self
      }.merge(@context)
    )
  end
end
