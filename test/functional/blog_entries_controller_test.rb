require 'test_helper'

class BlogEntriesControllerTest < ActionController::TestCase
  context "An BlogEntriesController" do
    setup do
      @project = Project.make
      @profile = login
      @project.promote_profile_to_originator(@profile)
    end

    context "on GET to :index" do
      setup do
        get :index, :project_id => @project.to_param
      end

      should_respond_with :success
      should_render_template :index
    end

    context "on GET to :index via AJAX by a non-originator" do
      setup do
        @project.memberships.destroy_all
        xhr :get, :index, :project_id => @project.to_param
      end

      should_respond_with :success
    end

    context "on GET to :new" do
      setup do
        get :new, :project_id => @project.to_param
      end

      should_respond_with :success
      should_render_template :new
    end

    context "on POST to :create" do
      context "with a valid blog_entry" do
        setup do
          post :create, :project_id => @project.to_param, :blog_entry => BlogEntry.plan
        end

        should_redirect_to("blog_entry list") { project_blog_entries_url(@project) }
        should_change("project blog_entry count", :by => 1) { @project.blog_entries.count }
      end

      context "with an invalid blog_entry" do
        setup do
          post :create, :project_id => @project.to_param, :blog_entry => BlogEntry.plan(:title => "")
        end

        should_respond_with :success
        should_render_template :new
        should_not_change("project blog_entry count") { @project.blog_entries.count }
      end
    end

    context "with an existing blog_entry" do
      setup do
        @blog_entry = BlogEntry.make(:project => @project)
      end

      context "on GET to :edit" do
        setup do
          get :edit, :project_id => @project.to_param, :id => @blog_entry.id
        end

        should_respond_with :success
        should_render_template :edit
      end

      context "on PUT to :update" do
        context "with a valid blog_entry" do
          setup do
            put :update, :project_id => @project.to_param, :id => @blog_entry.id,
              :blog_entry => { :title => "New!" }
          end

          should_redirect_to("blog_entry list") { project_blog_entries_url(@project) }
          should_change("blog_entry title", :to => "New!") { @blog_entry.reload.title }
        end

        context "with an invalid blog_entry" do
          setup do
            put :update, :project_id => @project.to_param, :id => @blog_entry.id,
              :blog_entry => { :title => "" }
          end

          should_respond_with :success
          should_render_template :edit
          should_not_change("blog_entry title") {  @blog_entry.reload.title }
        end
      end

      context "on DELETE to :destroy" do
        setup do
          delete :destroy, :project_id => @project.to_param, :id => @blog_entry.id
        end

        should_redirect_to("blog_entry list") { project_blog_entries_url(@project) }
        should_change("project blog_entry count", :by => -1) { @project.blog_entries.count }
      end
    end
  end
end
