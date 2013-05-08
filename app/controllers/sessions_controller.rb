class SessionsController < ApplicationController
  prepend_before_filter :require_https, :except => [:destroy]
  before_filter :require_no_profile, :only => [:new, :create]
  before_filter :require_profile, :only => :destroy
  before_filter :set_section

  def new
    full_width
    current_profile_session = ProfileSession.new
  end

  def create
    current = Profile.find_by_email(params[:profile_session][:email])
    if !current.nil? && current.active?
       current_profile_session = ProfileSession.new(params[:profile_session])
      if current_profile_session.save
        if !current.current_login_at.nil?
                   add_notice ( "Login successful!")
  session[:return_to] = nil
  session[:login_type]="normal"
          redirect_back_or_default dashboard_url
               else
          add_notice render_to_string(:partial => "/profiles/welcome_message")
          session[:return_to] = nil
           session[:login_type]="normal"
          redirect_back_or_default edit_profile_url
        end
      else
        @errors = ['Invalid email or password']
        render :action => :new
      end
    else
      @errors = ['Invalid email or password']
      render :action => :new
    end   
  end

  def destroy
    session[:profile_id]=nil
    if !current_profile_session.nil?
   current_profile_session.destroy
   end
    flash[:notice] = "Logout successful!"
    clear_session
    session[:login_type]= nil if session[:login_type].eql?("linkedin")
    redirect_to root_url
  end



  

 def logout_facebook
   session[:user_id]=nil
   session[:login_type]=nil
   session[:fb_session]=nil
   if !current_profile_session.nil?
   current_profile_session.destroy 
   end
clear_session
#   current_profile_session.destroy if current_profile_session
# clear_facebook_session_information
# clear_fb_cookies!
#  reset_session # remove your cookies!
# session[:login_type]= nil
 #clear_session
 #current_profile_session.destroy
 #reset_session # remove your cookies!
 flash[:notice] = "Your facebook session has expired."
 redirect_to root_url
 end

 




  private

  def set_section
    @section = "sign in"
  end
end
