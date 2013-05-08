require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  include ActionView::Helpers::UrlHelper

  context "A ProfilesController" do
    setup do
      https
      login
    end

    context "with some existing profiles" do
      setup do
        @bob = Profile.make(:username => "bob", :email => "robert.jones@gmail.com")
        Profile.make(:username => "steve", :email => "steve.jones@gmail.com")
      end

      context "searching by username" do
        setup do
          get :index, :val => "bob"
        end

        should_respond_with :success

        should "match on username" do
          result = JSON.parse(@response.body)
          assert_equal 1, result.size
          assert_equal "bob", result.first
        end
      end

      context "searching by email" do
        setup do
          get :index, :val => "jones"
        end

        should_respond_with :success

        should "match on email" do
          result = JSON.parse(@response.body)
          assert_equal 2, result.size
        end
      end

      context "on GET to :show" do
        setup do
          @request.env['HTTPS'] = false
          get :show, :id => @bob.id
        end

        should_respond_with :success
        should_render_template :show
      end
    end
  end

  test 'GET :new' do
    https
    get(:new)
    assert_response :success
    assert_template 'profiles/new'
  end

  # Should populate the invitation_token field from an invitation_token url param
  test 'GET :new w/ token in url' do
    https
    inv = Invite.make
    get(:new, { :invite_token => inv.token })
    assert_response :success
    assert_template 'profiles/new'
  end

  test 'GET :show' do
    profile = login
    get(:show, :id => profile.to_param)
    assert_response :success
    assert_template 'profiles/show'
  end

  test "cannot GET :show if not logged in" do
    get(:show)
    assert_redirected_to login_url
  end

  test 'POST :create' do
    https
    inv = Invite.make
    password = 'sesame'
    post(:create,
      { :invite_token => inv.token,
        :remember_me      => '0',
        :new_profile      => {
          :username              => 'george',
          :email                 => 'test@originalprojects.com',
          :display_name         => 'George',
          :city                  => 'Metropolis',
          :password              => password,
          :password_confirmation => password,
          :tos_accepted          => '1' }})

    assert ProfileSession.find
    assert_redirected_to dashboard_path
    assert flash[:messages][:notice].first =~ /Welcome to Original Projects/i
    inv.reload
    assert inv.accepted?
  end

  test 'POST :create w/o tos' do
    https
    inv = Invite.make
    password = 'sesame'
    post(:create,
      { :invite_token => inv.token,
        :new_profile      => {
          :username              => 'george',
          :email                 => 'test@originalprojects.com',
          :city                  => 'Metropolis',
          :password              => password,
          :password_confirmation => password,
          :tos_accepted          => '0' }})
    profile = assigns(:new_profile)
    assert profile.new_record?
    assert_response :success
    assert_template 'profiles/new'
    assert flash[:notice] !~ /registration success/i
    assert session[SESSION_PROFILE_ID].nil?
    assert_nil @response.cookies['auth_token']
    assert profile.errors.on(:base) =~ /must.*accepted/i
    inv.reload
    assert !inv.accepted?
  end

  test 'GET :edit' do
    https
    profile = login
    get(:edit)
    assert_response :success
    assert_template 'profiles/edit'
    assert_have_selector "input", :name => 'profile[username]'
  end

  test 'PUT :update' do
    https
    profile = login
    new_first_name = profile.first_name + 'z'
    put(:update,
      { :profile => {
          :city         => profile.city,
          :country      => profile.country,
          :display_name => profile.display_name,
          :email        => profile.email,
          :first_name   => new_first_name,
          :last_name    => profile.last_name,
          :phone_home   => profile.phone_home,
          :phone_mobile => profile.phone_mobile,
          :phone_office => profile.phone_office,
          :state        => profile.state,
          :url          => profile.url,
          :username     => profile.username,
          :links_attributes => [{:url => 'http://google.com'}, {:url => 'http://yahoo.com'}]
    } } )
    profile = assigns(:current_profile)
    assert profile
    assert_equal 2, profile.links.count
    assert_equal(new_first_name, profile.first_name)
    assert_redirected_to dashboard_path
    assert flash[:messages][:notice].first =~ /settings.*saved/i
  end
end
