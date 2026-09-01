require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "generates a slug from the name" do
    assert_equal "acme-consulting", Account.create!(name: "Acme Consulting").slug
  end

  test "requires a unique, url-safe slug" do
    refute Account.new(name: "Dup", slug: accounts(:studio).slug).valid?
    refute Account.new(name: "Spaces", slug: "not a slug").valid?
    assert Account.new(name: "Fine", slug: "fine-1").valid?
  end

  test "brand falls back to the app defaults for blank fields" do
    assert_equal accounts(:studio).tagline, accounts(:studio).brand[:tagline]
    assert_equal Rails.application.config.x.brand[:tagline], accounts(:rival).brand[:tagline]
    assert_equal "Rival Consulting", accounts(:rival).brand[:name]
  end

  test "destroying an account takes its users and briefs with it" do
    account = accounts(:rival)
    users = account.users.count
    briefs = account.briefs.count
    assert_difference "User.count", -users do
      assert_difference "Brief.count", -briefs do
        account.destroy!
      end
    end
  end
end
