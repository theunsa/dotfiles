require "test_helper"

class BriefTest < ActiveSupport::TestCase
  test "generates an unguessable slug from client_name on create" do
    brief = accounts(:studio).briefs.create!(client_name: "Acme Body Corporate")
    assert_match(/\A[a-z0-9]{4}-acme-body-corporate\z/, brief.slug)
  end

  test "does not overwrite an explicitly set slug" do
    brief = accounts(:studio).briefs.create!(client_name: "Acme", slug: "zzzz-fixed")
    assert_equal "zzzz-fixed", brief.slug
  end

  # Slugs are one shared URL space, so a second account cannot take one either.
  test "requires a globally unique slug" do
    accounts(:studio).briefs.create!(client_name: "Acme", slug: "dup-slug")
    duplicate = accounts(:rival).briefs.new(client_name: "Other", slug: "dup-slug")
    refute duplicate.valid?
  end

  test "rejects a non-E.164 whatsapp number but allows blank" do
    brief = accounts(:studio).briefs.new(client_name: "Acme", whatsapp_number: "0821234567")
    refute brief.valid?

    brief.whatsapp_number = ""
    brief.valid?
    refute brief.errors.key?(:whatsapp_number)
  end

  test "whatsapp_url is nil without a number and built correctly with one" do
    no_number = briefs(:draft)
    assert_nil no_number.whatsapp_url

    with_number = briefs(:acme)
    assert_includes with_number.whatsapp_url, "https://wa.me/27821234567?text="
  end

  test "passcode_protected? and authenticate_passcode" do
    open = briefs(:acme)
    refute open.passcode_protected?

    locked = briefs(:locked)
    assert locked.passcode_protected?
    assert locked.authenticate_passcode("sesame")
    refute locked.authenticate_passcode("wrong")
  end

end
