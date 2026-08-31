require "test_helper"

# The accept-block form is built by a partial rendered from inside MarkdownRenderer.
# Rendered outside the request (ApplicationController.render) `form_with` omits
# the CSRF token entirely and the button only works when Turbo happens to send
# the header — so these tests run with forgery protection actually on.
class AcceptFormTest < ActionDispatch::IntegrationTest
  setup do
    @original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  teardown { ActionController::Base.allow_forgery_protection = @original }

  test "accept form carries a CSRF token that the server accepts" do
    dossier = dossiers(:acme)

    get dossier_url(slug: dossier.slug)
    assert_response :success
    token = css_select("[data-block=accept] form input[name=authenticity_token]").first&.[]("value")
    assert token.present?, "accept form rendered without an authenticity_token"

    assert_difference "Acceptance.count", 1 do
      post dossier_acceptances_url(slug: dossier.slug),
           params: { label: "Accept Step 1", authenticity_token: token }
    end
    assert_redirected_to dossier_url(slug: dossier.slug)
  end

  test "a forged post without a token is still rejected" do
    assert_no_difference "Acceptance.count" do
      post dossier_acceptances_url(slug: dossiers(:acme).slug), params: { label: "Accept Step 1" }
    end
    assert_response :unprocessable_entity
  end
end
