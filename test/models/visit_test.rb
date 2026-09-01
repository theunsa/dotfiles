require "test_helper"

class VisitTest < ActiveSupport::TestCase
  test "record never stores the raw IP" do
    request = Struct.new(:user_agent, :remote_ip).new("TestAgent/1.0", "1.2.3.4")
    visit = Visit.record(briefs(:acme), request)

    refute_equal "1.2.3.4", visit.ip_hash
    assert_equal Visit.hash_ip("1.2.3.4"), visit.ip_hash
  end

  test "describes the device and browser behind a user agent" do
    iphone = Visit.new(user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1")
    assert_equal "iPhone · Safari", iphone.description

    # Chrome's UA also claims Safari, and Edge's claims both — the first match wins.
    chrome = Visit.new(user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36")
    assert_equal "Windows PC · Chrome", chrome.description

    edge = Visit.new(user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36 Edg/126.0")
    assert_equal "Windows PC · Edge", edge.description

    assert_equal "Unknown device", Visit.new(user_agent: "curl/8.4.0").description
  end

  test "visitor_id shortens the ip hash and tolerates a blank one" do
    assert_equal "abc123", Visit.new(ip_hash: "abc123def456").visitor_id
    assert_nil Visit.new(ip_hash: nil).visitor_id
  end
end
