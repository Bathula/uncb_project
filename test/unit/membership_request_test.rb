require 'test_helper'

class MembershipRequestTest < ActiveSupport::TestCase
  context "A MembershipRequest" do
    setup do
      @membership_request = MembershipRequest.make
    end

    subject { @membership_request }

    should_belong_to :project, :profile
    should_validate_presence_of :project, :profile
    should_validate_uniqueness_of :profile_id, :scoped_to => :project_id

    should "be invalid for projects that are not invite-only" do
      @membership_request.project.update_attribute(:membership_status, "open")
      assert !@membership_request.valid?
      assert_equal "is not invite-only", @membership_request.errors[:project]
    end

    should "be invalid for projects to which the profile is already a participant" do
      membership = Membership.make
      membership_request = MembershipRequest.make_unsaved(
        :profile => membership.profile,
        :project => membership.project)

      assert !membership_request.valid?
      assert_equal "is already a member of this project", membership_request.errors[:profile]
    end
  end
end
