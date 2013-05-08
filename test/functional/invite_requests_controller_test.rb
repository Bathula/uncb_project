require 'test_helper'

class InviteRequestsControllerTest < ActionController::TestCase
  context "on GET to :new" do
    setup do
      get :new
    end

    should "be successful" do
      assert_response :success
      assert_template 'invite_requests/new'
    end
  end

  context "on POST to :create" do
    should "add an invite request" do
      assert_difference "InviteRequest.count" do
        post :create, :invite_request => InviteRequest.plan
      end
    end
  end

end
