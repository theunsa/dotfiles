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

  test "invalid YAML inside a block does not raise" do
    md = "::steps\n---\nitems: [unclosed\n---\n::"
    assert_nothing_raised { MarkdownRenderer.new(md).to_html }
  end

  test "accept_block? detects the accept block" do
    assert MarkdownRenderer.new("::accept{label=\"Go\"}\n::").accept_block?
    refute MarkdownRenderer.new("plain text").accept_block?
  end
end
