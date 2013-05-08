module AccountBehavior
  def self.included(base)
    base.module_eval do
      filter_parameter_logging :password, :password_confirmation
      helper_method :current_profile_session, :current_profile, :logged_in?
     #before_filter :login_from_fb
    end
  end

  private

  def current_profile_session
   if session[:login_type]=='facebook'
      puts "facebook session"
       #login_from_facebook
        @current_profile_session=Profile.find_by_facebook_id(session[:user_id])
      elsif !session[:profile_id].nil?
        puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        @current_profile_session=Profile.find(session[:profile_id])
    end
    return @current_profile_session if defined?(@current_profile_session)
    @current_profile_session = ProfileSession.find
   
  end

    def current_profile

    if session[:login_type]=='facebook'
      puts "facebook session"
       #login_from_facebook
        @current_profile=Profile.find_by_facebook_id(session[:user_id])
      elsif !session[:profile_id].nil?
puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        @current_profile=Profile.find(session[:profile_id])
    end
    return @current_profile if defined?(@current_profile)
  @current_profile = (current_profile_session && current_profile_session.profile)
    
      end

  
#    def login_from_facebook
#     if session[:login_type]=='facebook'
#
#       session[:fb_session] = Profile.find_by_facebook_id(session[:user_id])
#     end
#
#
#    end
   


#  def login_from_fb
##    if request_comes_from_facebook?
##     if ensure_authenticated_to_facebook
##
##    end
##  end
# end

#  def check_if_fb_app_installed?
#    if request_comes_from_facebook?
#      ensure_application_is_installed_by_facebook_user
#    end
#  end
  
  alias_method :logged_in?, :current_profile

  def require_profile
   #add_notice "Important Notice! This site is more compactable with Safari, Google Chrome, Mozilla Firefox"
    @profile = current_profile and return if current_profile
    
    store_location
    flash[:notice] = "You must be signed in to access this page"
    
    redirect_to login_url
    return false
  end
  
  def require_no_profile
    if current_profile
      store_location
      flash[:notice] = "You must be signed out to access this page"
      redirect_to dashboard_url
      return false
    end
  end
end
