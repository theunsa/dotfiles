require "test_helper"

class DossierTest < ActiveSupport::TestCase
  test "generates an unguessable slug from client_name on create" do
    dossier = Dossier.create!(client_name: "Acme Body Corporate")
    assert_match(/\A[a-z0-9]{4}-acme-body-corporate\z/, dossier.slug)
  end

  test "does not overwrite an explicitly set slug" do
    dossier = Dossier.create!(client_name: "Acme", slug: "zzzz-fixed")
    assert_equal "zzzz-fixed", dossier.slug
  end

  test "requires a unique slug" do
    Dossier.create!(client_name: "Acme", slug: "dup-slug")
    duplicate = Dossier.new(client_name: "Other", slug: "dup-slug")
    refute duplicate.valid?
  end

  test "rejects a non-E.164 whatsapp number but allows blank" do
    dossier = Dossier.new(client_name: "Acme", whatsapp_number: "0821234567")
    refute dossier.valid?

    dossier.whatsapp_number = ""
    dossier.valid?
    refute dossier.errors.key?(:whatsapp_number)
  end

  test "whatsapp_url is nil without a number and built correctly with one" do
    no_number = dossiers(:draft)
    assert_nil no_number.whatsapp_url

    with_number = dossiers(:acme)
    assert_includes with_number.whatsapp_url, "https://wa.me/27821234567?text="
  end

  test "passcode_protected? and authenticate_passcode" do
    open = dossiers(:acme)
    refute open.passcode_protected?

    locked = dossiers(:locked)
    assert locked.passcode_protected?
    assert locked.authenticate_passcode("sesame")
    refute locked.authenticate_passcode("wrong")
  end

  test "accepted? reflects acceptances" do
    dossier = dossiers(:acme)
    refute dossier.accepted?
    dossier.acceptances.create!(label: "Accept Step 1")
    assert dossier.accepted?
  end
end
