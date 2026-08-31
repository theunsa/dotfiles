# Renders dossier markdown: GFM via Commonmarker, plus custom blocks written as
# fenced code blocks whose language is a block name — ```steps / ```callout /
# ```faq / ```accept — containing YAML, mapped to partials in app/views/markdown/.
#
# A fence is standard CommonMark, so a dossier body is a plain markdown file
# everywhere: any other editor shows the blocks as highlighted YAML instead of
# mangling them, and any other fence language (```ruby …) passes through to
# Commonmarker untouched and renders as ordinary code.
class MarkdownRenderer
  BLOCK_START = /\A```(?<name>[a-z][a-z0-9-]*)\s*\z/
  # Flush-left only, so an indented ``` inside a YAML block scalar (e.g. a code
  # sample in `body: |`) doesn't close the fence early.
  BLOCK_END = /\A```\s*\z/
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
        ```steps
        items:
          - title: Discovery
            price: R 18 000 fixed
            body: You get a working demo and a written scope.
            note: This is all you commit to today.
          - title: Go live
            price: R 60 000
            body: The real thing, on your own domain.
        ```
      MD
    },
    "callout" => {
      label: "Callout",
      placeholder: "You only commit to Step 1",
      body: <<~MD
        ```callout
        title: You only commit to Step 1
        body: Every step is priced **before** it starts. Stop whenever you like.
        ```
      MD
    },
    "faq" => {
      label: "FAQ",
      placeholder: "What if I stop after Step 1?",
      body: <<~MD
        ```faq
        items:
          - label: What if I stop after Step 1?
            content: You keep the demo. No penalty, no notice period.
          - label: Who owns the code?
            content: You do.
        ```
      MD
    },
    "accept" => {
      label: "Accept",
      placeholder: "Accept Step 1",
      body: <<~MD
        ```accept
        label: Accept Step 1
        ```
      MD
    }
  }.freeze
  # Dates/times are ordinary things to write in block YAML; without them
  # permitted, Psych raises and the whole block's data silently disappears.
  YAML_CLASSES = [ Date, Time, DateTime ].freeze

  # context: extra locals handed to block partials (e.g. dossier: for accept).
  def initialize(source, context: {})
    @source = source.to_s
    @context = context
  end

  # `view` is the ActionView context of the request being served — pass it (from
  # a template, that's `self`). Block partials that build forms need the real
  # request: rendered through ApplicationController.render they sit outside it,
  # `protect_against_forgery?` is false, and `form_with` quietly omits the CSRF
  # token, so the accept block only submits when Turbo happens to supply the header.
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
      match = line.chomp.match(BLOCK_START)
      if match && KNOWN_BLOCKS.include?(match[:name])
        j = i + 1
        j += 1 while j < lines.length && !lines[j].chomp.match?(BLOCK_END)
        if j < lines.length
          result << { type: :markdown, text: buffer.join } if buffer.any?
          buffer = []
          result << build_block(match[:name], lines[(i + 1)...j], block_index)
          block_index += 1
          i = j + 1
          next
        end
        # No closing "```" — leave the line to Commonmarker, which renders the
        # unclosed fence as a code block to end of document: visible, not lost.
      end
      buffer << line
      i += 1
    end
    result << { type: :markdown, text: buffer.join } if buffer.any?
    result
  end

  # The fence body is YAML and nothing else. Returns data as a Hash; a non-nil
  # error means the block renders as a visible parse-error box rather than
  # vanishing.
  def build_block(name, block_lines, block_index)
    data, error = parse_yaml(block_lines.join)
    { type: :block, name: name, index: block_index, data: data, error: error }
  end

  def parse_yaml(yaml)
    data = YAML.safe_load(yaml, permitted_classes: YAML_CLASSES)
    return [ {}, nil ] if data.nil?
    return [ {}, "expected settings like `title: …`, got #{data.class.name.downcase}" ] unless data.is_a?(Hash)
    [ data, nil ]
  rescue Psych::Exception => e
    [ {}, e.message ]
  end

  def markdown_to_html(text)
    return "" if text.strip.empty?
    # hardbreaks: false — Commonmarker turns every source newline into a <br>
    # by default, so text wrapped at 80 columns keeps those breaks on a phone
    # and reads as ragged half-lines. Off, paragraphs reflow to the reader's
    # screen; a deliberate break is still two trailing spaces, as in any markdown.
    #
    # syntax_highlighter: nil — Commonmarker's bundled themes are fixed colour
    # schemes that inline a dark background, which fights the light UI and
    # ignores the reader's theme. Plain markup instead, styled by .dossier-prose.
    Commonmarker.to_html(text,
      options: {
        render: { unsafe: false, hardbreaks: false },
        extension: { header_ids: nil, table: true, strikethrough: true, autolink: true, tasklist: true }
      },
      plugins: { syntax_highlighter: nil })
  end

  def block_to_html(seg, view)
    partial = seg[:error] ? "parse_error" : seg[:name]

    locals = {
      name: seg[:name],
      block_index: seg[:index],
      data: seg[:data],
      error: seg[:error],
      renderer: self
    }.merge(@context)

    renderer = view || ApplicationController
    renderer.render(partial: "markdown/#{partial}", locals: locals)
  end
end
