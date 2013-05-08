require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  context "An ImagesController" do
    setup do
      @project = Project.make
      @profile = login
    end

    context "without a logged-in member" do
      setup { get :edit, :project_id => @project.to_param }
      should_respond_with 401
    end

    context "with a logged-in member" do
      setup do
        @project.profiles << @profile
      end

      context "on GET to :edit" do
        setup do
          get :edit, :project_id => @project.to_param
        end

        should_respond_with :success
        should_render_template :edit
      end

      context "on PUT to :update" do
        context "with image data" do
          setup do
            put :update, :project_id => @project.to_param,
              :project => { :images_attributes => { 1 => {
                :attachment => File.open(RAILS_ROOT + "/public/images/rails.png") } } }
          end

          should_redirect_to("project image page") { edit_project_images_url(@project) }
          should_change("project image count", :by => 1) { @project.images.count }
        end

        context "with a new project title" do
          setup do
            put :update, :project_id => @project.to_param, :project => { :title => "New Title!" }
          end

          should_not_change("project title") { @project.reload.title }
        end
      end
    end
  end
end
