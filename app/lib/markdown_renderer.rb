# Renders dossier markdown: GFM via Commonmarker, plus the prototype's MDC-style
# blocks (::steps / ::callout / ::faq / ::accept) mapped to partials in
# app/views/markdown/. The `::name … ::` syntax is kept exactly as in
# nuxt-prototype/ so existing content pastes in unchanged.
class MarkdownRenderer
  BLOCK_START = /\A::(?<name>[a-z][a-z0-9-]*)(?:\{(?<attrs>[^}]*)\})?\s*\z/
  BLOCK_END   = /\A::\s*\z/
  KNOWN_BLOCKS = %w[steps callout faq accept].freeze

  # Starter markdown for the admin editor's insert chips. Prefilled with real
  # content rather than empty skeletons — editing something down is quicker than
  # filling a blank in. `placeholder` is the substring the editor selects after
  # inserting, so the author can type straight over it.
  #
  # Kept here beside KNOWN_BLOCKS so a snippet can't drift from what the parser
  # accepts; markdown_renderer_test asserts every one of these round-trips.
  SNIPPETS = {
    "steps" => {
      label: "Steps",
      placeholder: "Discovery",
      body: <<~MD
        ::steps
        ---
        items:
          - title: Discovery
            price: R 18 000 fixed
            body: You get a working demo and a written scope.
            note: This is all you commit to today.
          - title: Go live
            price: R 60 000
            body: The real thing, on your own domain.
        ---
        ::
      MD
    },
    "callout" => {
      label: "Callout",
      placeholder: "You only commit to Step 1",
      body: <<~MD
        ::callout{title="You only commit to Step 1"}
        Every step is priced **before** it starts. Stop whenever you like.
        ::
      MD
    },
    "faq" => {
      label: "FAQ",
      placeholder: "What if I stop after Step 1?",
      body: <<~MD
        ::faq
        ---
        items:
          - label: What if I stop after Step 1?
            content: You keep the demo. No penalty, no notice period.
          - label: Who owns the code?
            content: You do.
        ---
        ::
      MD
    },
    "accept" => {
      label: "Accept",
      placeholder: "Accept Step 1",
      body: <<~MD
        ::accept{label="Accept Step 1"}
        ::
      MD
    }
  }.freeze
  # Dates/times are ordinary things to write in block front matter; without them
  # permitted, Psych raises and the whole block's data silently disappears.
  YAML_CLASSES = [ Date, Time, DateTime ].freeze

  # context: extra locals handed to block partials (e.g. dossier: for ::accept).
  def initialize(source, context: {})
    @source = source.to_s
    @context = context
  end

  # `view` is the ActionView context of the request being served — pass it (from
  # a template, that's `self`). Block partials that build forms need the real
  # request: rendered through ApplicationController.render they sit outside it,
  # `protect_against_forgery?` is false, and `form_with` quietly omits the CSRF
  # token, so ::accept only submits when Turbo happens to supply the header.
  # The fallback exists for unit tests and other non-request callers.
  def to_html(view = nil)
    segments.map do |seg|
      seg[:type] == :markdown ? markdown_to_html(seg[:text]) : block_to_html(seg, view)
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
    block_index = 0
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
          result << build_block(match, block_lines, block_index)
          block_index += 1
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

  def build_block(match, block_lines, block_index)
    data, body, error = split_front_matter(block_lines)
    {
      type: :block,
      name: match[:name],
      index: block_index,
      attrs: parse_attrs(match[:attrs]),
      data: data,
      body: body,
      error: error
    }
  end

  # Inside a block, an optional YAML section is delimited by `---` … `---`.
  # Returns [data, body, error]; a non-nil error means the block renders as a
  # visible parse-error box rather than vanishing (same rule as unknown blocks).
  def split_front_matter(block_lines)
    stripped = block_lines.drop_while { |l| l.strip.empty? }
    return [ {}, block_lines.join, nil ] unless stripped.first&.chomp&.strip == "---"

    closing = stripped[1..].index { |l| l.chomp.strip == "---" }
    return [ {}, block_lines.join, "front matter opened with --- but never closed" ] unless closing

    yaml = stripped[1..closing].join
    body = stripped[(closing + 2)..].to_a.join
    [ YAML.safe_load(yaml, permitted_classes: YAML_CLASSES) || {}, body, nil ]
  rescue Psych::Exception => e
    [ {}, block_lines.join, e.message ]
  end

  # {title="Foo" icon="i-lucide-shield-check"} → { "title" => "Foo", ... }
  def parse_attrs(attrs)
    attrs.to_s.scan(/([a-z][a-z0-9-]*)="([^"]*)"/).to_h
  end

  def markdown_to_html(text)
    return "" if text.strip.empty?
    Commonmarker.to_html(text, options: { render: { unsafe: false }, extension: { header_ids: nil } })
  end

  def block_to_html(seg, view)
    partial =
      if seg[:error] then "parse_error"
      elsif KNOWN_BLOCKS.include?(seg[:name]) then seg[:name]
      else "unknown"
      end

    locals = {
      name: seg[:name],
      block_index: seg[:index],
      attrs: seg[:attrs],
      data: seg[:data],
      body_html: markdown_to_html(seg[:body]).html_safe,
      error: seg[:error],
      renderer: self
    }.merge(@context)

    renderer = view || ApplicationController
    renderer.render(partial: "markdown/#{partial}", locals: locals)
  end
end
