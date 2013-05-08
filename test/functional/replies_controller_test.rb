require 'test_helper'

class RepliesControllerTest < ActionController::TestCase
  context "A RepliesController" do
    setup do
      @profile = login
      @comment = Comment.make
    end

    context "on POST to :create" do
      setup do
        post :create, :comment_id => @comment.to_param,
          :reply => { :content => "What a great comment." }
      end

      should_redirect_to("project page w/ comments visible") { project_url(@comment.project, :anchor => "comments") }
      should_change("comment replies count", :by => 1) { @comment.replies.count }
    end
  end
end
