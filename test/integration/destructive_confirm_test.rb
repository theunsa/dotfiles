require "test_helper"

# button_to with a block wraps its content in its own <button>, so rendering the
# button component inside one produced nested buttons. The parser hoists those
# apart, and the button you actually click ends up without the data-turbo-confirm
# — deleting a dossier with no prompt at all. Assert the shape, not just the
# attribute: the attribute was present the whole time, on the wrong element.
class DestructiveConfirmTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "the delete button is a single button carrying the confirm" do
    get admin_dossier_url(dossiers(:acme))
    assert_response :success

    button = css_select("form[action='#{admin_dossier_path(dossiers(:acme))}'] button")
    assert_equal 1, button.size, "expected exactly one button in the delete form"
    assert_empty button.first.css("button"), "delete button must not contain another button"
    assert button.first["data-turbo-confirm"].present?, "the clickable button carries no confirm"
    assert_equal "destructive", button.first["data-variant"]
  end

  test "the confirm names what is destroyed" do
    dossier = dossiers(:acme)
    dossier.visits.create!(viewed_at: Time.current)

    get admin_dossier_url(dossier)
    confirm = css_select("form[action='#{admin_dossier_path(dossier)}'] button").first["data-turbo-confirm"]

    assert_includes confirm, dossier.client_name
    assert_includes confirm, "1 visit"
    assert_includes confirm, "cannot be undone"
  end

  test "log out is a single button too" do
    get admin_root_url
    button = css_select("form[action='#{session_path}'] button")

    assert_equal 1, button.size
    assert_empty button.first.css("button")
  end

  test "the confirm dialog is rendered for the author but not for a client" do
    get admin_root_url
    assert_select "dialog.alert-dialog[data-controller=confirm-dialog]"

    sign_out
    get dossier_url(slug: dossiers(:acme).slug)
    assert_response :success
    assert_select "dialog.alert-dialog", false, "the client's page should carry no admin chrome"
  end
end
