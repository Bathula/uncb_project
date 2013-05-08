require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test 'GET :show' do
    login
    get :show
    assert_response :success
    assert_template 'dashboard/show'
  end
end
