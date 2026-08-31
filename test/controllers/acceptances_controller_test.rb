require "test_helper"

class AcceptancesControllerTest < ActionDispatch::IntegrationTest
  test "accept button records an acceptance once" do
    slug = dossiers(:acme).slug

    assert_difference "Acceptance.count", 1 do
      post dossier_acceptances_url(slug: slug), params: { label: "Accept Step 1" }
      post dossier_acceptances_url(slug: slug), params: { label: "Accept Step 1" }
    end
    assert_redirected_to dossier_url(slug: slug)
    assert_equal "Accept Step 1", Acceptance.last.label

    get dossier_url(slug: slug)
    assert_select "[data-block=accept]", text: /Accepted on/
  end

  test "acceptance on a locked dossier requires unlock" do
    assert_no_difference "Acceptance.count" do
      post dossier_acceptances_url(slug: dossiers(:locked).slug), params: { label: "Go" }
    end
    assert_redirected_to dossier_unlock_url(slug: dossiers(:locked).slug)
  end
end
