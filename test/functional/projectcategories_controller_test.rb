require 'test_helper'

class ProjectcategoriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projectcategories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create projectcategory" do
    assert_difference('Projectcategory.count') do
      post :create, :projectcategory => { }
    end

    assert_redirected_to projectcategory_path(assigns(:projectcategory))
  end

  test "should show projectcategory" do
    get :show, :id => projectcategories(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => projectcategories(:one).to_param
    assert_response :success
  end

  test "should update projectcategory" do
    put :update, :id => projectcategories(:one).to_param, :projectcategory => { }
    assert_redirected_to projectcategory_path(assigns(:projectcategory))
  end

  test "should destroy projectcategory" do
    assert_difference('Projectcategory.count', -1) do
      delete :destroy, :id => projectcategories(:one).to_param
    end

    assert_redirected_to projectcategories_path
  end
end
