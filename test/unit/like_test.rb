require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  context "A Like" do
    setup do
      @like = Like.make
    end

    subject { @like }

    should_belong_to :project, :profile
    should_validate_presence_of :project, :profile
    should_validate_uniqueness_of :profile_id, :scoped_to => :project_id
  end
end
