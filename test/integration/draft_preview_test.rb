require "test_helper"

# Drafts 404 for the world but stay visible to the signed-in author, so a
# brief can be checked on its real page before it goes live.
class DraftPreviewTest < ActionDispatch::IntegrationTest
  setup do
    @draft = briefs(:draft)
    @draft.documents.create!(title: "Draft proposal", body_markdown: "## Not live yet\n")
  end

  test "anonymous visitors still get a 404" do
    get brief_url(slug: @draft.slug)
    assert_response :not_found
  end

  test "the author sees the page with a draft banner" do
    sign_in_as users(:one)
    get brief_url(slug: @draft.slug)

    assert_response :success
    assert_select "[data-draft-banner]"
    assert_select "[data-draft-banner] a[href=?]", edit_admin_brief_path(@draft)
    assert_select "h1", "Draft proposal"
  end

  test "a published brief shows no draft banner" do
    sign_in_as users(:one)
    get brief_url(slug: briefs(:acme).slug)

    assert_response :success
    assert_select "[data-draft-banner]", false
  end

  test "previewing a draft records no visit" do
    sign_in_as users(:one)
    assert_no_difference "Visit.count" do
      get brief_url(slug: @draft.slug)
    end
  end

end
