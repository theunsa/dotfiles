require "test_helper"

class Admin::DossiersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "requires authentication" do
    delete session_url
    get admin_root_url
    assert_redirected_to new_session_url
  end

  test "index lists dossiers" do
    get admin_root_url
    assert_response :success
    assert_select "td", text: dossiers(:acme).client_name
  end

  test "create builds a dossier with a document" do
    assert_difference [ "Dossier.count", "Document.count" ], 1 do
      post admin_dossiers_url, params: {
        dossier: {
          client_name: "New Co",
          whatsapp_number: "+27821234567",
          published: "1",
          documents_attributes: { "0" => { title: "Proposal", body_markdown: "## Hi" } }
        }
      }
    end
    assert_redirected_to admin_dossier_path(Dossier.last)
  end

  test "update can remove a passcode" do
    locked = dossiers(:locked)
    patch admin_dossier_url(locked), params: { dossier: { client_name: locked.client_name, remove_passcode: "1" } }
    assert_redirected_to admin_dossier_path(locked)
    refute locked.reload.passcode_protected?
  end

  test "destroy removes the dossier" do
    dossier = dossiers(:draft)
    assert_difference "Dossier.count", -1 do
      delete admin_dossier_url(dossier)
    end
    assert_redirected_to admin_root_path
  end
end
