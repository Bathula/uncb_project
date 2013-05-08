require 'test_helper'

class LikesControllerTest < ActionController::TestCase
  context "A LikesController" do
    setup do
      @project = Project.make
      @profile = login
    end

    context "on POST to :create" do
      setup do
        post :create, :project_id => @project.to_param
      end

      should_redirect_to("project page") { project_url(@project) }
      should_change("number of project likes", :by => 1) { @project.likes.count }
    end

    context "with a like which the user owns" do
      setup do
        @like = Like.make(:project => @project, :profile => @profile)
      end

      context "on DELETE to :destroy" do
        setup do
          delete :destroy, :project_id => @project.to_param, :id => @like.id
        end

        should_redirect_to("project page") { project_url(@project) }
        should_change("number of project likes", :by => -1) { @project.likes.count }
      end
    end

    context "with a like which the user does not own" do
      setup do
        @like = Like.make(:project => @project)
      end

      context "on DELETE to :destroy" do
        setup do
          delete :destroy, :project_id => @project.to_param, :id => @like.id
        end

        should_respond_with 401
        should_not_change("number of project likes") { @project.likes.count }
      end
    end
  end
end
