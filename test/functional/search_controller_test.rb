require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  context "A SearchController" do
    setup do
      ThinkingSphinx.stubs(:search).returns([])
    end

    context "doing a default search" do
      setup do
        login
        get :index, :q => "title"
      end

      should_respond_with :success
      should_render_template :index
    end
  end
end
