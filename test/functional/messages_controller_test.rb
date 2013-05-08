require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  context "A MessagesController" do
    setup do
      @profile = login
      @friend = Profile.make
    end

    context "on GET to :new" do
      setup do
        get :new, :profile_id => @friend.to_param
      end

      should_respond_with :success
      should_render_template :new
    end

    context "on POST to :create" do
      context "with good data" do
        setup do
          post :create, :profile_id => @friend.to_param,
            :message => { :subject => "Hello", :body => "How are you?" }
        end

        before_should "send a message" do
          Mailer.expects(:deliver_user_specified_message).returns(true)
        end

        should_redirect_to("profile page") { @friend }
        should_change("friend's message count", :by => 1) { @friend.messages.count }
      end

      context "with good data" do
        setup do
          post :create, :profile_id => @friend.to_param,
            :message => { :subject => "Hello", :body => "" }
        end

        should_respond_with :success
        should_render_template :new
        should_not_change("friend's message count") { @friend.messages.count }
      end
    end
  end
end
