require "test_helper"

# The client-facing light/dark switch. It ships hidden and Stimulus reveals it,
# so a reader without JS is never shown a control that cannot do anything.
class ThemeToggleTest < ActionDispatch::IntegrationTest
  test "a published brief carries the toggle, hidden until Stimulus connects" do
    get brief_url(slug: briefs(:acme).slug)

    assert_response :success
    assert_select "header button[data-controller=?][hidden]", "theme"
    assert_select "header button[data-action=?]", "theme#toggle"
  end

  test "the stored choice is applied before paint" do
    get brief_url(slug: briefs(:acme).slug)

    assert_match 'localStorage.getItem("brief.theme")', response.body
  end
end
