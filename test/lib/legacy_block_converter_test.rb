require "test_helper"

class LegacyBlockConverterTest < ActiveSupport::TestCase
  test "converts a directive with attributes into a fenced block" do
    converted = LegacyBlockConverter.call(<<~MD)
      ::callout{title="Heads up"}
      ::
    MD

    assert_equal "```callout\ntitle: Heads up\n```\n", converted
  end

  test "merges attributes, front matter and free text into one YAML block" do
    converted = LegacyBlockConverter.call(<<~MD)
      ::callout{title="Heads up"}
      Every step is priced **before** it starts.
      ::
    MD

    data = YAML.safe_load(converted.lines[1..-2].join)
    assert_equal "Heads up", data["title"]
    assert_equal "Every step is priced **before** it starts.", data["body"]
  end

  test "converts front matter items and the result renders as the block" do
    converted = LegacyBlockConverter.call(<<~MD)
      ::steps
      ---
      items:
        - title: Discovery
          price: R 18 000
      ---
      ::
    MD

    html = MarkdownRenderer.new(converted).to_html
    assert_includes html, 'data-block="steps"'
    assert_includes html, "Discovery"
    refute_includes html, 'data-block="parse-error"'
  end

  test "leaves surrounding markdown untouched" do
    converted = LegacyBlockConverter.call("## Title\n\ntext\n")
    assert_equal "## Title\n\ntext\n", converted
  end

  # The data migration selects on a bare "::" match, so it hands the converter
  # plenty of text with no directive in it at all.
  test "text that only mentions colons is not mangled" do
    source = "See the `Foo::Bar` class, and ::not a block\n"
    assert_equal source, LegacyBlockConverter.call(source)
  end

  test "running it twice is a no-op" do
    once = LegacyBlockConverter.call("::callout{title=\"Go\"}\n::\n")
    assert_equal once, LegacyBlockConverter.call(once)
  end

  test "an unclosed directive is left exactly as written" do
    source = "::steps\nno closing marker\n"
    assert_equal source, LegacyBlockConverter.call(source)
  end
end
