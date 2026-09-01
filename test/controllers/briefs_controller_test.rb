require "test_helper"

class BriefsControllerTest < ActionDispatch::IntegrationTest
  test "shows a published brief with noindex" do
    get brief_url(slug: briefs(:acme).slug)
    assert_response :success
    assert_equal "noindex, nofollow, noarchive, noimageindex", response.headers["X-Robots-Tag"]
    assert_select "h1", text: documents(:acme_proposal).title
  end

  test "unpublished brief 404s" do
    get brief_url(slug: briefs(:draft).slug)
    assert_response :not_found
  end

  test "unknown slug 404s" do
    get brief_url(slug: "nope")
    assert_response :not_found
  end

  test "records one visit per session within the dedupe window" do
    assert_difference "Visit.count", 1 do
      get brief_url(slug: briefs(:acme).slug)
      get brief_url(slug: briefs(:acme).slug)
    end
    refute_equal "127.0.0.1", Visit.last.ip_hash
  end

  test "passcode-protected brief redirects to unlock" do
    get brief_url(slug: briefs(:locked).slug)
    assert_redirected_to brief_unlock_url(slug: briefs(:locked).slug)
  end

  test "correct passcode unlocks and wrong one does not" do
    slug = briefs(:locked).slug

    post brief_unlock_url(slug: slug), params: { passcode: "wrong" }
    assert_redirected_to brief_unlock_url(slug: slug)

    post brief_unlock_url(slug: slug), params: { passcode: "sesame" }
    assert_redirected_to brief_url(slug: slug)

    get brief_url(slug: slug)
    assert_response :success
  end
end
