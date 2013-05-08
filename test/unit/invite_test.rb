require 'test_helper'

class InviteTest < ActiveSupport::TestCase
  context "An Invite" do
    should_validate_presence_of :token, :invite_request

    should "have a token set" do
      invite = Invite.new
      assert_not_nil invite.token
    end

    should "try until it gets a valid token" do
      Invite.make(:token => "TEST_TOKEN")
      Digest::SHA1.expects(:hexdigest).at_least(2).returns("TEST_TOKEN", "UNIQUE_TOKEN")

      invite = Invite.make_unsaved
      assert_not_nil invite.token
      assert_equal 'UNIQUE_TOKEN', invite.token
    end

    should "detect if it has been accepted?" do
      invite = Invite.new
      assert !invite.accepted?
      
      invite.accept
      assert invite.accepted?
    end
  end
end
