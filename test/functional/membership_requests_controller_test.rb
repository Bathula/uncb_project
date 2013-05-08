require 'test_helper'

class MembershipRequestsControllerTest < ActionController::TestCase
  context "A MembershipRequestController" do
    setup do
      @profile = login
      @project = Project.make(:membership_status => "invite")
    end

    context "on POST to :create" do
      setup do
        post :create, :project_id => @project.id
      end

      should_redirect_to("project page") { @project }
      should_change("project's membership request count", :by => 1) { @project.membership_requests.count }
    end

    context "with a closed project" do
      setup do
        @project.update_attribute(:membership_status, "closed")
      end

      context "on POST to :create" do
        setup do
          post :create, :project_id => @project.id
        end

        should_redirect_to("project page") { @project }
        should_not_change("project's membership request count") { @project.membership_requests.count }
      end
    end

    context "with a project the profile is already participating in" do
      setup do
        @project.add_participant(@profile)
      end

      context "on POST to :create" do
        setup do
          post :create, :project_id => @project.id
        end

        should_redirect_to("project page") { @project }
        should_not_change("project's membership request count") { @project.membership_requests.count }
      end
    end

    context "with an existing membership request" do
      setup do
        @project.promote_profile_to_originator(@profile)
        @mr = MembershipRequest.make(:project => @project)
      end

      context "on DELETE to :destroy" do
        setup do
          delete :destroy, :project_id => @project.id, :id => @mr.id
        end

        should_redirect_to("project member list") { project_members_url(@project) }
        should_change("project membership requests count", :by => -1) { @project.membership_requests.count }
      end
    end
  end
end
