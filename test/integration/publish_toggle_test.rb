require "test_helper"

class PublishToggleTest < ActionDispatch::IntegrationTest
  test "publishing from the admin form makes the public page reachable" do
    d = briefs(:draft)

    # Signed out: a draft is invisible. (Signed in it is previewable — see
    # DraftPreviewTest — so this has to be checked before authenticating.)
    get brief_url(slug: d.slug)
    assert_response :not_found

    sign_in_as users(:one)
    patch admin_brief_url(d), params: { brief: { published: "1" } }
    assert d.reload.published?

    sign_out
    get brief_url(slug: d.slug)
    assert_response :success
  end
end
