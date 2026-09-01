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

  test "rejects a non-E.164 number for whatsapp and phone but allows blank" do
    brief = accounts(:studio).briefs.new(client_name: "Acme", cta_kind: "whatsapp", cta_value: "0821234567")
    refute brief.valid?

    brief.cta_kind = "phone"
    refute brief.valid?

    brief.cta_value = ""
    brief.valid?
    refute brief.errors.key?(:cta_value)
  end

  test "rejects a non-address for an email cta" do
    brief = accounts(:studio).briefs.new(client_name: "Acme", cta_kind: "email", cta_value: "+27821234567")
    refute brief.valid?

    brief.cta_value = "hi@example.com"
    brief.valid?
    refute brief.errors.key?(:cta_value)
  end

  test "rejects an unknown cta_kind" do
    brief = accounts(:studio).briefs.new(client_name: "Acme", cta_kind: "carrier-pigeon")
    refute brief.valid?
  end

  test "cta_url is nil without a value and per kind with one" do
    assert_nil briefs(:draft).cta_url

    brief = briefs(:acme)
    assert_includes brief.cta_url, "https://wa.me/27821234567?text="
    assert_equal "WhatsApp me", brief.cta_label

    brief.update!(cta_kind: "phone")
    assert_equal "tel:+27821234567", brief.cta_url
    assert_equal "Call me", brief.cta_label

    brief.update!(cta_kind: "email", cta_value: "hi@example.com", cta_text: "Step 1")
    assert_equal "mailto:hi@example.com?subject=Step%201", brief.cta_url
    assert_equal "Email me", brief.cta_label
  end

  # "None" is the off switch: the value stays on the record, the button does not.
  test "cta_url is nil when the kind is none" do
    brief = briefs(:acme)
    brief.update!(cta_kind: "none")
    assert_nil brief.cta_url
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
