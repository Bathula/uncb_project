require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  #------------------------------------------------------------
  # :login
  #------------------------------------------------------------

  test 'GET :new' do
    https
    get(:new)
    assert_response :success
    assert_template 'sessions/new'
    assert_have_selector "input", :name => 'profile_session[username]'
    assert_have_selector "input", :name => 'profile_session[password]'
  end

  test 'POST :create' do
    https
    username = 'kermit'
    password = 'sesame'
    profile = Profile.make(:username => username, :password => password)
    logout
    post(:create, { :profile_session => { :username => username, :password => password } })
    assert_redirected_to dashboard_path
    assert ProfileSession.find    
  end

  test 'POST :create w/ invalid credentials' do
    https
    post(:create, { :profile_session => {:username => 'abc', :password => ''} })    
    assert_template 'sessions/new'
    errors = assigns(:errors)
    assert errors.include?('Invalid username or password')
  end

  #------------------------------------------------------------
  # :logout
  #------------------------------------------------------------

  test 'DELETE :destroy' do
    username = 'kermit'
    password = 'sesame'
    profile = Profile.make(:username => username, :password => password)
    delete(:destroy)
    assert_redirected_to root_url
    assert_nil ProfileSession.find
  end 
end
