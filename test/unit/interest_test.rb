require 'test_helper'

class InterestTest < ActiveSupport::TestCase
  context "An Interest" do
    setup do
      @interest = Interest.make
    end

    subject { @interest }

    should_belong_to :project, :profile
    should_validate_presence_of :project, :profile
    should_validate_uniqueness_of :profile_id, :scoped_to => :project_id
  end
end
