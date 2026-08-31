require "test_helper"

class PublishToggleTest < ActionDispatch::IntegrationTest
  test "publishing from the admin form makes the public page reachable" do
    d = dossiers(:draft)

    # Signed out: a draft is invisible. (Signed in it is previewable — see
    # DraftPreviewTest — so this has to be checked before authenticating.)
    get dossier_url(slug: d.slug)
    assert_response :not_found

    sign_in_as users(:one)
    patch admin_dossier_url(d), params: { dossier: { published: "1" } }
    assert d.reload.published?

    sign_out
    get dossier_url(slug: d.slug)
    assert_response :success
  end
end
