require "test_helper"

class Admin::PreviewsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    post admin_preview_url, params: { body_markdown: "## Hi" }
    assert_redirected_to new_session_url
  end

  test "renders markdown through the real renderer, without a layout" do
    sign_in_as users(:one)
    post admin_preview_url, params: { body_markdown: MarkdownRenderer::SNIPPETS["steps"][:body] }

    assert_response :success
    assert_includes response.body, 'data-block="steps"'
    assert_includes response.body, "Discovery"
    refute_includes response.body, "<html", "preview fragment should not carry the layout"
  end

  test "an accept block in the preview is not a working button" do
    sign_in_as users(:one)
    post admin_preview_url, params: { body_markdown: MarkdownRenderer::SNIPPETS["accept"][:body] }

    assert_response :success
    assert_select "button[disabled]"
    assert_select "form", false
  end

  test "blank markdown previews without blowing up" do
    sign_in_as users(:one)
    post admin_preview_url, params: { body_markdown: "" }

    assert_response :success
    assert_includes response.body, "Nothing to preview yet."
  end

  test "raw HTML in the markdown is still escaped in the preview" do
    sign_in_as users(:one)
    post admin_preview_url, params: { body_markdown: "<script>alert(1)</script>" }

    assert_response :success
    refute_includes response.body, "<script>alert(1)</script>"
  end
end
