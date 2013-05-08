class PasswordsController < ApplicationController
  before_filter :load_profile_from_token, :only => [:show, :update]
  before_filter :set_section
  before_filter :full_width

  def new
    render
  end

  def create
    profile = Profile.find_by_email(params[:email])
    if profile
      profile.deliver_password_reset_instructions
      add_notice "Check your email for instructions for resetting your password."
      redirect_to new_password_url
    else
      add_error "We could not find a profile matching that email address.", :now => true
      render :action => :new
    end
  end

  def show
    render
  end

  def update
    if @profile.update_attributes(params[:profile])
      redirect_to root_url
    else
      render :action => :show
    end
  end

  def activation_link
    render
  end

  def send_activation
    profile = Profile.find_by_email(params[:email])
    if profile
      Mailer.deliver_activation_link(profile)
      add_notice "Check your email to activate your account."
      redirect_to activation_url
    else
      add_error "We could not find a profile matching that email address.", :now => true
      render :action => :new
    end
  end

  def email_linkedin
    params[:id]=request.cookies['window_name']
    params[:last_name]=request.cookies['window_last_name']
    params[:first_name]=request.cookies['window_first_name']

    find_linkedin_id = Profile.find_by_member_id(params[:id])
   
    if find_linkedin_id.nil? 
      session[:login_type]="linkedin"
      redirect_to  signup_forlinkedin_url
    else
      ProfileSession.create(find_linkedin_id)
      session[:login_type]="linkedin"
      redirect_to dashboard_url

    end
  end


  def signup_forlinkedin

    session[:login_type]="linkedin"
    @new_profile = Profile.new

  end

  def delete_linkedin
    clear_session
    reset_session # remove your cookies!
    redirect_to root_url
  end

  def email_check
  
    if facebook_session
      session[:login_type]="facebook"
      @profile = Profile.find_by_facebook_id(facebook_session.user.id)
      if !@profile.nil?
        ProfileSession.create(@profile)
        add_notice "Logged in succesful"
        session[:login_type]="facebook"
        redirect_to dashboard_url
      else
         
        render :email_check
      end
    end
  end

 


  def email_check_update

    @profile = Profile.find_by_email(params[:profile][:email])
    if !@profile.nil? && @profile.active?
      current_profile_session = ProfileSession.new(params[:profile])
      if current_profile_session.save
        @profile.update_attributes(:facebook_id => params[:facebook_id],:session_key => params[:session_key])
        ProfileSession.create(@profile)
        add_notice "Logged in succesful"
        redirect_to dashboard_url
      else
        @errors = ['Invalid username or password']
        render :email_check
      end
    else
      @errors = ['Invalid username or password']
      render :email_check
    end
  end

  def email_checklinkedin_update
        
    @profile = Profile.find_by_email(params[:profile][:email])
    if !@profile.nil? && @profile.active?
      current_profile_session = ProfileSession.new(params[:profile])
      if current_profile_session.save
        @profile.update_attributes(:network=>"linkedin",:member_id=>params[:member_id])
        ProfileSession.create(@profile)
        add_notice "Logged in succesful"
        redirect_to dashboard_url
      else
        @errors = ['Invalid username or password']
        render :signup_forlinkedin
      end
    else
      
      @errors = ['Invalid username or password']
      render :signup_forlinkedin
    end
  end


  private

  def load_profile_from_token
    @profile = Profile.find_using_perishable_token(params[:id])
    if @profile.nil?
      add_notice "We couldn't find your account. " +
        "Your reset window might have expired, or you could have followed a bad link."
      redirect_to new_password_url
    end
  end

  def set_section
    @section = :dashboard
  end
end

