require 'test_helper'

class RemarksControllerTest < ActionController::TestCase
  context "A RemarksController" do
    setup do
      @profile = login
      @blog_entry = BlogEntry.make
    end

    context "on POST to :create" do
      setup do
        post :create, :project_id => @blog_entry.project.to_param, :blog_entry_id => @blog_entry.to_param,
          :remark => { :content => "What a great update." }
      end

      should_redirect_to("project page w/ blog visible") { project_url(@blog_entry.project, :anchor => "blog") }
      should_change("blog entry remarks count", :by => 1) { @blog_entry.remarks.count }
    end
  end
end
