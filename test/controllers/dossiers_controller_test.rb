require "test_helper"

class DossiersControllerTest < ActionDispatch::IntegrationTest
  test "shows a published dossier with noindex" do
    get dossier_url(slug: dossiers(:acme).slug)
    assert_response :success
    assert_equal "noindex, nofollow, noarchive, noimageindex", response.headers["X-Robots-Tag"]
    assert_select "h1", text: documents(:acme_proposal).title
  end

  test "unpublished dossier 404s" do
    get dossier_url(slug: dossiers(:draft).slug)
    assert_response :not_found
  end

  test "unknown slug 404s" do
    get dossier_url(slug: "nope")
    assert_response :not_found
  end

  test "records one visit per session within the dedupe window" do
    assert_difference "Visit.count", 1 do
      get dossier_url(slug: dossiers(:acme).slug)
      get dossier_url(slug: dossiers(:acme).slug)
    end
    refute_equal "127.0.0.1", Visit.last.ip_hash
  end

  test "passcode-protected dossier redirects to unlock" do
    get dossier_url(slug: dossiers(:locked).slug)
    assert_redirected_to dossier_unlock_url(slug: dossiers(:locked).slug)
  end

  test "correct passcode unlocks and wrong one does not" do
    slug = dossiers(:locked).slug

    post dossier_unlock_url(slug: slug), params: { passcode: "wrong" }
    assert_redirected_to dossier_unlock_url(slug: slug)

    post dossier_unlock_url(slug: slug), params: { passcode: "sesame" }
    assert_redirected_to dossier_url(slug: slug)

    get dossier_url(slug: slug)
    assert_response :success
  end
end
