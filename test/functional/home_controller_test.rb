require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HomeControllerTest < ActionController::TestCase
  test 'GET :index' do
    get(:index)
    assert_response :success
  end

  test 'GET :tos' do
    get :tos
    assert_response :success
    assert_template 'tos'
  end
end
