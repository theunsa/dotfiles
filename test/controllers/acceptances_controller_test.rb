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

  test "each ::accept block is accepted on its own label" do
    dossier = dossiers(:acme)
    dossier.documents.first.update!(body_markdown: <<~MD)
      ::accept{label="Accept Step 1"}
      ::

      ::accept{label="Accept Step 2"}
      ::
    MD

    post dossier_acceptances_url(slug: dossier.slug), params: { label: "Accept Step 1" }

    get dossier_url(slug: dossier.slug)
    # Step 1 shows as accepted; step 2 must still offer its button.
    assert_select "[data-block=accept]", 2
    assert_select "[data-block=accept] button", text: "Accept Step 2"

    assert_difference "Acceptance.count", 1 do
      post dossier_acceptances_url(slug: dossier.slug), params: { label: "Accept Step 2" }
    end
    assert_equal [ "Accept Step 1", "Accept Step 2" ], dossier.acceptances.order(:accepted_at).pluck(:label)
  end

  test "acceptance on a locked dossier requires unlock" do
    assert_no_difference "Acceptance.count" do
      post dossier_acceptances_url(slug: dossiers(:locked).slug), params: { label: "Go" }
    end
    assert_redirected_to dossier_unlock_url(slug: dossiers(:locked).slug)
  end
end
