require "test_helper"

class Admin::BriefsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "requires authentication" do
    delete session_url
    get admin_root_url
    assert_redirected_to new_session_url
  end

  test "index lists briefs" do
    get admin_root_url
    assert_response :success
    assert_select "td", text: briefs(:acme).client_name
  end

  test "edit offers every cta kind and preselects the brief's" do
    get edit_admin_brief_url(briefs(:acme))
    assert_response :success
    assert_select "select#brief_cta_kind option", count: Brief::CTA_KINDS.size
    assert_select "select#brief_cta_kind option[selected][value=whatsapp]"
  end

  test "show summarises each visit and hides the raw detail behind a disclosure" do
    Visit.create!(brief: briefs(:acme), viewed_at: Time.current, ip_hash: "abc123def456",
                  user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 Version/17.5 Safari/604.1")

    get admin_brief_url(briefs(:acme))
    assert_response :success
    assert_select "td details summary", text: /iPhone · Safari/
    assert_select "td details dd", text: /Mozilla\/5.0 \(iPhone/
  end

  test "create builds a brief with a document" do
    assert_difference [ "Brief.count", "Document.count" ], 1 do
      post admin_briefs_url, params: {
        brief: {
          client_name: "New Co",
          cta_kind: "whatsapp",
          cta_value: "+27821234567",
          published: "1",
          documents_attributes: { "0" => { title: "Proposal", body_markdown: "## Hi" } }
        }
      }
    end
    assert_redirected_to admin_brief_path(Brief.last)
  end

  test "update can remove a passcode" do
    locked = briefs(:locked)
    patch admin_brief_url(locked), params: { brief: { client_name: locked.client_name, remove_passcode: "1" } }
    assert_redirected_to admin_brief_path(locked)
    refute locked.reload.passcode_protected?
  end

  test "destroy removes the brief" do
    brief = briefs(:draft)
    assert_difference "Brief.count", -1 do
      delete admin_brief_url(brief)
    end
    assert_redirected_to admin_root_path
  end
end
