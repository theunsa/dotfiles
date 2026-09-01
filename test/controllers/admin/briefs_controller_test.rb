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

  test "create builds a brief with a document" do
    assert_difference [ "Brief.count", "Document.count" ], 1 do
      post admin_briefs_url, params: {
        brief: {
          client_name: "New Co",
          whatsapp_number: "+27821234567",
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
