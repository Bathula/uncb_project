require 'test_helper'

class InviteRequestTest < ActiveSupport::TestCase
  context "An InviteRequest" do
    should_validate_presence_of :name, :email, :city, :country

    should "require a description if project" do
      invite_request = InviteRequest.make_unsaved(:project => true)
      assert !invite_request.valid?
      invite_request.project_description = "It's a mat that lets you jump to conclusions."
      assert invite_request.valid?
    end

    should "be able to be invited" do
      invite_request = InviteRequest.make

      assert_difference("Invite.count") { invite_request.send_invite }
    end
  end
end
