require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  context "An Activity" do
    should_validate_presence_of :subject
    should_belong_to :subject, :profile, :project

    context "with an existing project" do
      setup { @project = Project.make }

      context "adding an originator" do
        setup { @project.promote_profile_to_originator(Profile.make) }
        should_change("activity count", :by => 1) { Activity.count }
      end

      context "adding a comment" do
        setup do
          @comment = Comment.make(:project => @project)
        end

        should_change("activity count", :by => 1) { Activity.count }

        should "create an activity with the project as its project" do
          assert_equal Activity.last.project, @project
          assert_equal Activity.last.subject, @comment
        end
      end
    end
  end
end
