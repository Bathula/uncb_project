require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
  context "A PasswordsController" do
    setup do
      @profile = Profile.make
    end

    context "on GET to #new" do
      setup do
        get :new
      end

      should_respond_with :success
      should_render_template :new
    end

    context "on POST to #create" do
      context "with an existing email" do
        setup do
          post :create, :email => @profile.email
        end

        should_redirect_to("new password page") { new_password_url }
        should_change("perishable token") { @profile.reload.perishable_token }
      end

      context "with a non-existing email" do
        setup do
          post :create, :email => "xxxxxx"
        end

        should_respond_with :success
        should_render_template :new
      end
    end

    context "on GET to #show" do
      setup do
        get :show, :id => @profile.perishable_token
      end

      should_respond_with :success
      should_render_template :show
    end

    context "on PUT to :update" do
      context "with a valid token" do
        context "and matching passwords" do
          setup do
            put :update, :id => @profile.perishable_token,
              :profile => { :password => "newpass", :password_confirmation => "newpass" }
          end

          should_redirect_to("homepage") { root_url }
          should_change("encrypted password") { @profile.reload.password_hash }
        end

        context "and non-matching passwords" do
          setup do
            put :update, :id => @profile.perishable_token,
              :profile => { :password => "newpass", :password_confirmation => "oldpass" }
          end

          should_respond_with :success
          should_render_template :show
          should_not_change("encrypted password") { @profile.reload.password_hash }
        end
      end

      context "with an invalid token" do
        setup do
          put :update, :id => "xxx"
        end

        should_redirect_to("new password page") { new_password_url }
      end
    end
  end
end
