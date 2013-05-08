require 'test_helper'

class MembersControllerTest < ActionController::TestCase
  context "A MembersController" do
    setup do
      @profile = login
      @project = Project.make(:membership_status => "invite")
      @project.promote_profile_to_originator(@profile)
      @project.add_participant(Profile.make)
    end

    context "on GET to :index" do
      setup do
        get :index, :project_id => @project.id
      end

      should_respond_with :success
      should_render_template :index
    end

    context "with a membership request" do
      setup do
        @requester = Profile.make
        MembershipRequest.make(:project => @project, :profile => @requester)
      end

      context "on POST to :create" do
        setup do
          post :create, :project_id => @project.id, :member => { :profile_id => @requester.id }
        end

        should_redirect_to("project member list") { project_members_url(@project) }
        should_change("number of project members", :by => 1) { @project.memberships.count }
        should_change("number of membership requests", :by => -1) { @project.membership_requests.count }
      end
    end

    context "with an existing member" do
      setup do
        @member = Profile.make
        @project.add_participant(@member)
      end

      context "on DELETE to :destroy" do
        setup do
          delete :destroy, :project_id => @project.slug, :id => @member.id
        end

        should_change("number of project members", :by => -1) { @project.members.count }
      end

      context "on POST to :promote" do
        setup do
          post :promote, :project_id => @project.slug, :id => @member.id
        end

        should_change("number of project originators", :by => 1) { @project.originators.count }
        should_change("number of project members", :by => -1) { @project.members.count }
      end
    end
  end
end
