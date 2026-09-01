require "test_helper"

class VisitTest < ActiveSupport::TestCase
  test "record never stores the raw IP" do
    request = Struct.new(:user_agent, :remote_ip).new("TestAgent/1.0", "1.2.3.4")
    visit = Visit.record(briefs(:acme), request)

    refute_equal "1.2.3.4", visit.ip_hash
    assert_equal Visit.hash_ip("1.2.3.4"), visit.ip_hash
  end
end
