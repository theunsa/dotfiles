require "test_helper"

class MarkdownRendererTest < ActiveSupport::TestCase
  test "renders plain markdown" do
    html = MarkdownRenderer.new("## Hello\n\nSome *text*.").to_html
    assert_includes html, "<h2>Hello</h2>"
    assert_includes html, "<em>text</em>"
  end

  test "escapes raw HTML in markdown" do
    html = MarkdownRenderer.new("<script>alert(1)</script>").to_html
    refute_includes html, "<script>"
  end

  test "renders ::steps with YAML items and inline markdown" do
    md = <<~MD
      ::steps
      ---
      items:
        - title: Discovery
          price: R 18 000 fixed
          body: You get a *working demo*.
          note: This is all you commit to today.
        - title: Go live
          price: R 60 000
      ---
      ::
    MD
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, 'data-block="steps"'
    assert_includes html, "Discovery"
    assert_includes html, "R 18 000 fixed"
    assert_includes html, "<em>working demo</em>"
    assert_includes html, "Step 2"
  end

  test "renders ::callout with attrs and markdown body" do
    md = <<~MD
      ::callout{title="You only commit to Step 1"}
      Every step is priced **before** it starts.
      ::
    MD
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, 'data-block="callout"'
    assert_includes html, "You only commit to Step 1"
    assert_includes html, "<strong>before</strong>"
  end

  test "renders ::faq items as details elements" do
    md = <<~MD
      ::faq
      ---
      items:
        - label: Does this replace WeConnectU?
          content: No. It stays.
      ---
      ::
    MD
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, "<details"
    assert_includes html, "Does this replace WeConnectU?"
  end

  test "markdown around blocks still renders" do
    md = "before\n\n::callout\nhi\n::\n\nafter"
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, "before"
    assert_includes html, "after"
    assert_includes html, 'data-block="callout"'
  end

  test "unknown block renders a visible box instead of vanishing" do
    html = MarkdownRenderer.new("::wat\nhello\n::").to_html
    assert_includes html, 'data-block="unknown"'
    assert_includes html, "::wat"
  end

  test "unclosed block start is treated as text" do
    html = MarkdownRenderer.new("::steps\nno closing marker").to_html
    refute_includes html, 'data-block="steps"'
  end

  test "invalid YAML inside a block does not raise, and says so visibly" do
    md = "::steps\n---\nitems: [unclosed\n---\n::"
    html = nil
    assert_nothing_raised { html = MarkdownRenderer.new(md).to_html }
    assert_includes html, 'data-block="parse-error"'
  end

  test "unclosed front matter renders a parse error rather than an empty block" do
    md = "::steps\n---\nitems:\n  - title: A\n::"
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, 'data-block="parse-error"'
    refute_includes html, 'data-block="steps"'
  end

  test "dates in block front matter parse instead of silently emptying the block" do
    md = <<~MD
      ::steps
      ---
      items:
        - title: Discovery
          due: 2026-01-01
      ---
      ::
    MD
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, 'data-block="steps"'
    assert_includes html, "Discovery"
    refute_includes html, 'data-block="parse-error"'
  end

  test "faq accordion groups get stable names across renders" do
    md = "::faq\n---\nitems:\n  - label: Q\n    content: A\n---\n::"
    assert_equal MarkdownRenderer.new(md).to_html, MarkdownRenderer.new(md).to_html
    assert_includes MarkdownRenderer.new(md).to_html, 'name="faq-0"'
  end

  # The editor chips insert these verbatim, so a snippet that no longer parses
  # would hand the author broken markdown with no warning.
  test "every known block has a snippet, and every snippet renders as that block" do
    assert_equal MarkdownRenderer::KNOWN_BLOCKS.sort, MarkdownRenderer::SNIPPETS.keys.sort

    MarkdownRenderer::SNIPPETS.each do |name, snippet|
      html = MarkdownRenderer.new(snippet[:body], context: { preview: true }).to_html

      assert_includes html, %(data-block="#{name}"), "#{name} snippet did not render as a #{name} block"
      refute_includes html, 'data-block="unknown"', "#{name} snippet rendered as an unknown block"
      refute_includes html, 'data-block="parse-error"', "#{name} snippet failed to parse"
      assert_includes snippet[:body], snippet[:placeholder],
        "#{name} placeholder is not present in its own snippet, so the editor cannot select it"
    end
  end

  test "accept renders inert in preview so a proofread cannot record an acceptance" do
    html = MarkdownRenderer.new(MarkdownRenderer::SNIPPETS["accept"][:body], context: { preview: true }).to_html

    assert_includes html, "disabled"
    refute_includes html, "<form"
  end

  test "accept_block? detects the accept block" do
    assert MarkdownRenderer.new("::accept{label=\"Go\"}\n::").accept_block?
    refute MarkdownRenderer.new("plain text").accept_block?
  end
end
