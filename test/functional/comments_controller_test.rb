require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  context "A CommentsController" do
    setup do
      @profile = login
      @project = Project.make
    end

    context "on POST to :create" do
      setup do
        post :create, :project_id => @project.to_param,
          :comment => { :content => "What a great project." }
      end

      should_redirect_to("project page w/ comments visible") { project_url(@project, :anchor => "comments") }
      should_change("project comment count", :by => 1) { @project.comments.count }
    end
  end
end
