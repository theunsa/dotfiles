require "test_helper"

# One account must never reach another's data, and a public brief page must
# wear the brand of the account that owns it.
class TenantIsolationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # belongs to accounts(:studio)
    @theirs = briefs(:rival_published)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "admin index lists only this account's briefs" do
    get admin_root_url
    assert_response :success
    assert_select "td", text: briefs(:acme).client_name
    assert_select "td", text: @theirs.client_name, count: 0
  end

  test "another account's brief 404s everywhere in admin" do
    get admin_brief_url(@theirs)
    assert_response :not_found

    get edit_admin_brief_url(@theirs)
    assert_response :not_found

    patch admin_brief_url(@theirs), params: { brief: { client_name: "Stolen" } }
    assert_response :not_found

    assert_no_difference "Brief.count" do
      delete admin_brief_url(@theirs)
    end
    assert_response :not_found
    assert_equal "Rival Client", @theirs.reload.client_name
  end

  test "a new brief belongs to the signing-in user's account" do
    post admin_briefs_url, params: {
      brief: { client_name: "New Co", published: "1",
                 documents_attributes: { "0" => { title: "Proposal", body_markdown: "## Hi" } } }
    }
    assert_equal accounts(:studio), Brief.find_by(client_name: "New Co").account
  end

  test "being signed in elsewhere does not unlock another account's brief" do
    get brief_url(slug: briefs(:rival_locked).slug)
    assert_redirected_to brief_unlock_url(slug: briefs(:rival_locked).slug)
  end

  test "being signed in elsewhere does not reveal another account's draft" do
    get brief_url(slug: briefs(:rival_draft).slug)
    assert_response :not_found
  end

  test "a public page wears the owning account's brand" do
    delete session_url
    get brief_url(slug: @theirs.slug)
    assert_response :success
    assert_select "header a", text: accounts(:rival).name
  end

  test "the author's own views still do not count as visits" do
    assert_no_difference "Visit.count" do
      get brief_url(slug: briefs(:acme).slug)
    end
  end

  test "a signed-in user's view of another account's brief counts as a visit" do
    assert_difference "Visit.count", 1 do
      get brief_url(slug: @theirs.slug)
    end
  end
end
