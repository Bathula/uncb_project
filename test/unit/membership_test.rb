require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  context "A Membership" do
    setup do
      @membership = Membership.make
    end

    subject { @membership }

    should_belong_to :project, :profile
    should_validate_presence_of :project, :profile
    should_validate_uniqueness_of :profile_id, :scoped_to => :project_id

    context "being created" do
      setup { Membership.make }
      should_change("the number of followers", :by => 1) { Interest.count }
    end
  end
end
