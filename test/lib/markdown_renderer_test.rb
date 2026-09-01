require "test_helper"

class MarkdownRendererTest < ActiveSupport::TestCase
  test "renders plain markdown" do
    html = MarkdownRenderer.new("## Hello\n\nSome *text*.").to_html
    assert_includes html, "<h2>Hello</h2>"
    assert_includes html, "<em>text</em>"
  end

  # Dossier source is wrapped at ~80 columns; those breaks must not survive into
  # the client's page, where they would read as ragged half-lines on a phone.
  test "wrapped source reflows instead of keeping its line breaks" do
    html = MarkdownRenderer.new("A sentence that was\nwrapped in the editor.").to_html
    refute_includes html, "<br"
  end

  test "a deliberate hard break is still honoured" do
    html = MarkdownRenderer.new("Line one.  \nLine two.").to_html
    assert_includes html, "<br"
  end

  test "renders GFM tables" do
    html = MarkdownRenderer.new("| a | b |\n|---|---|\n| 1 | 2 |").to_html
    assert_includes html, "<table>"
  end

  test "escapes raw HTML in markdown" do
    html = MarkdownRenderer.new("<script>alert(1)</script>").to_html
    refute_includes html, "<script>"
  end

  test "renders a steps fence with YAML items and inline markdown" do
    md = <<~MD
      ```steps
      items:
        - title: Discovery
          price: R 18 000 fixed
          body: You get a *working demo*.
          note: This is all you commit to today.
        - title: Go live
          price: R 60 000
      ```
    MD
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, 'data-block="steps"'
    assert_includes html, "Discovery"
    assert_includes html, "R 18 000 fixed"
    assert_includes html, "<em>working demo</em>"
    assert_includes html, "Step 2"
  end

  test "renders a callout fence with title and markdown body" do
    md = <<~MD
      ```callout
      title: You only commit to Step 1
      body: Every step is priced **before** it starts.
      ```
    MD
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, 'data-block="callout"'
    assert_includes html, "You only commit to Step 1"
    assert_includes html, "<strong>before</strong>"
  end

  test "renders faq items as details elements" do
    md = <<~MD
      ```faq
      items:
        - label: Does this replace WeConnectU?
          content: No. It stays.
      ```
    MD
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, "<details"
    assert_includes html, "Does this replace WeConnectU?"
  end

  test "markdown around blocks still renders" do
    md = "before\n\n```callout\nbody: hi\n```\n\nafter"
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, "before"
    assert_includes html, "after"
    assert_includes html, 'data-block="callout"'
  end

  test "ordinary code fences pass through to Commonmarker untouched" do
    html = MarkdownRenderer.new("```ruby\nputs 1\n```").to_html
    assert_includes html, '<pre lang="ruby"'
    assert_includes html, "puts 1"
    refute_includes html, "data-block"
    # Highlighting is off, so the markup carries no baked-in colour scheme for
    # .dossier-prose to fight over.
    refute_includes html, "background-color"
  end

  test "unclosed block fence is left to Commonmarker as a visible code block" do
    html = MarkdownRenderer.new("```steps\nno closing fence").to_html
    refute_includes html, 'data-block="steps"'
    assert_includes html, "no closing fence"
  end

  test "invalid YAML inside a block does not raise, and says so visibly" do
    md = "```steps\nitems: [unclosed\n```"
    html = nil
    assert_nothing_raised { html = MarkdownRenderer.new(md).to_html }
    assert_includes html, 'data-block="parse-error"'
  end

  test "YAML that is not key-value settings renders a parse error, not a crash" do
    html = MarkdownRenderer.new("```steps\njust a sentence\n```").to_html
    assert_includes html, 'data-block="parse-error"'
    refute_includes html, 'data-block="steps"'
  end

  test "an indented fence inside a YAML block scalar does not close the block" do
    md = <<~MD
      ```callout
      title: With code
      body: |
        ```sh
        echo hi
        ```
      ```
    MD
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, 'data-block="callout"'
    assert_includes html, "echo hi"
  end

  test "dates in block YAML parse instead of silently emptying the block" do
    md = <<~MD
      ```steps
      items:
        - title: Discovery
          due: 2026-01-01
      ```
    MD
    html = MarkdownRenderer.new(md).to_html
    assert_includes html, 'data-block="steps"'
    assert_includes html, "Discovery"
    refute_includes html, 'data-block="parse-error"'
  end

  test "faq accordion groups get stable names across renders" do
    md = "```faq\nitems:\n  - label: Q\n    content: A\n```"
    assert_equal MarkdownRenderer.new(md).to_html, MarkdownRenderer.new(md).to_html
    assert_includes MarkdownRenderer.new(md).to_html, 'name="faq-0"'
  end

  # The editor chips insert these verbatim, so a snippet that no longer parses
  # would hand the author broken markdown with no warning.
  test "every known block has a snippet, and every snippet renders as that block" do
    assert_equal MarkdownRenderer::KNOWN_BLOCKS.sort, MarkdownRenderer::SNIPPETS.keys.sort

    MarkdownRenderer::SNIPPETS.each do |name, snippet|
      html = MarkdownRenderer.new(snippet[:body]).to_html

      assert_includes html, %(data-block="#{name}"), "#{name} snippet did not render as a #{name} block"
      refute_includes html, 'data-block="parse-error"', "#{name} snippet failed to parse"
      assert_includes snippet[:body], snippet[:placeholder],
        "#{name} placeholder is not present in its own snippet, so the editor cannot select it"
    end
  end

end
