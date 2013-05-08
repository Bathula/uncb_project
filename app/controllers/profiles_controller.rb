class ProfilesController < ApplicationController
  prepend_before_filter :require_https, :except => [:show, :logout]
  before_filter :require_profile, :except => [:new,:edit,:update,:create, :index, :show,:check_email,:check_username]
  before_filter :add_console, :only => [:edit, :update]
  before_filter :set_console_section, :only => [ :edit, :show, :update ]

  def index
    render :json => Profile.search_display_name_and_email(params[:val]).map(&:display_name)

  end

  def new
    @new_profile = Profile.new
    session[:login_type]=nil
  end
 
  def show
    if params[:id]
      @profile = Profile.find(params[:id])
    elsif logged_in?
      add_console
      add_notice('This is how your profile currently appears. <a href="/my_profile/edit">Edit your profile...</a>', :now => true)
      @profile = current_profile
    end    
    @originated_projects = @profile.originated_projects.visible
    @collaborating_projects = @profile.member_projects.visible
    @followed_projects = @profile.followed_projects.visible - @profile.originated_projects
    @services = @profile.services
  end

  def create
   
    auth_hash = request.env['omniauth.auth']
    
    if auth_hash
     
      params[:new_profile]={:display_name=>auth_hash["info"]["name"],:email=>auth_hash["info"]["email"],:password=>"brilliance",:password_confirmation=>"brilliance",:facebook_id=>auth_hash["uid"]}
      session[:user_id]=auth_hash["uid"]
      session[:login_type]='facebook'
      
    end


    @profile=Profile.find_by_email(params[:new_profile][:email]) if !params[:new_profile][:facebook_id].nil?
    if @profile
      if @profile.facebook_id.nil?
       @profile.facebook_id=params[:new_profile][:facebook_id]
      end

      #      session[:user_id]=auth_hash["uid"]
      #      session[:login_type]='facebook'

      # current_profile
      if @profile.last_login_at.nil?
        @profile.last_login_at=Time.now
        @profile.save
                
        puts Time.now
        Mailer.deliver_mail_to_linkedin_or_facebook_connect(@profile)
        redirect_to edit_profile_url


      else
        @profile.last_login_at=Time.now
        @profile.save
        redirect_to dashboard_path
      end
      



    else

      @new_profile = Profile.new(params[:new_profile])
#      if auth_hash
#        @new_profile.remote_avatar_url=auth_hash["info"]["image"]
#      end
      
      respond_to do |format|
        format.html do
          if  @new_profile.new_record? && @new_profile.valid?
            
            @new_profile.newsletter = params[:newsletter] ||=0
        
            if params[:new_profile][:member_id] || params[:new_profile][:facebook_id]
              
              @new_profile.active=1
            end
            
            @new_profile.save

              


            
         
            MessageSetting.create(:profile_id=>@new_profile.id,:messages_sent=>true)
            #adding newsletter from mailchimp
            #        if  @new_profile.newsletter=="1"
            #             h = Hominid::Base.new({:api_key => 'c0d8e1a5fd6db89021120c3c4c79125d-us1'})
            #             list = h.lists.find {|list| list["name"] == "original projects test" }
            #             h.subscribe(list["id"],@new_profile.email)
            #             end
            if @new_profile.member_id || @new_profile.facebook_id
#              @default_project=Project.find_by_slug("original-projects-inc")
#              puts @default_project.inspect
#              @follow_original_projects =Interest.create(:profile_id=>@new_profile.id,:project_id=>@default_project.id)
              @profile_op_community_join =Activity.create(:subject_id=>@new_profile.id,:subject_type=>"Profile",:profile_id=>@new_profile.id)
              #@activity_feed = Activity.create(:subject_id=>@follow_original_projects.id,:subject_type=> "Interest",:profile_id=>@new_profile.id,:project_id=>@default_project.id)

 end




            if @new_profile.member_id || @new_profile.facebook_id
              if @new_profile.last_login_at.nil?
                @new_profile.last_login_at=Time.now
                @new_profile.save
                add_notice render_to_string(:partial => "/profiles/welcome_message")
                Mailer.deliver_mail_to_linkedin_or_facebook_connect(@new_profile)
                redirect_to edit_profile_url
    

              else
                redirect_to dashboard_path
              end
            else
              add_notice "Please check your email to activate your account."
              @new_profile.send_email
              redirect_to root_url
             
            end
          
            


         
          else
            # session[:user_id]=nil
            #  session[:login_type]=nil
            render :new
          end
        end
      end
    end
    
  end

  def edit
      puts "xxxxxxxxxxxxxxxxxxxxxxxxx"
    if params[:perishable_token]
      
      @current_profile = Profile.find_by_email(params[:email])
     
      if @current_profile.perishable_token==params[:perishable_token] && !@current_profile.active?
        #@default_project=Project.find_by_slug("original-projects-inc")
        @activate = @current_profile.update_attributes(:active => "1")
        #@follow_original_projects = Interest.create(:profile_id=>@current_profile.id,:project_id=>@default_project.id)
        @profile_op_community_join = Activity.create(:subject_id=>@current_profile.id,:subject_type=> "Profile",:profile_id=>@current_profile.id)
        #@activity_feed = Activity.create(:subject_id=>@follow_original_projects.id,:subject_type=> "Interest",:profile_id=>@current_profile.id,:project_id=>@default_project.id)
        #@project=Project.find_by_slug("original-projects-inc")
        #@project.followups.each do |user|
         # Mailer.send_later(:deliver_follows_original_project,@project,@current_profile,user.display_name,user.email)
        #end

        puts "xxxxxxxxxxxxxxxxxxxxxxxxx"
        
          add_notice render_to_string(:partial => "/profiles/welcome_message")
          session[:return_to] = nil
           session[:login_type]="normal"
           session[:profile_id]=@current_profile.id
           puts "xxxxxxxxxxxxxxxxxxxxxxxxx3333333"
        puts session[:profile_id]
        redirect_back_or_default edit_profile_url
          #redirect_back_or_default edit_profile_url
        
      
      





#        add_notice 'Your account has been activated. Please login to get started.'
#        redirect_to login_path
        # new message settings record is created
      
        #adding newsletter from mailchimp
        if  @current_profile.newsletter=="1"
          h = Hominid::Base.new({:api_key => 'c0d8e1a5fd6db89021120c3c4c79125d-us1'})
          list = h.lists.find {|list| list["name"] == "original projects test" }
          h.subscribe(list["id"],@current_profile.email)
        end

      else
        render :edit
      end
    end
    #    add_notice 'Your account has been activated. Please login to get started.'
  end

  def update
    
   
    if current_profile.update_attributes(params[:profile])
      add_notice 'Your profile has been successfully updated'
      redirect_to dashboard_path
      
    else
      add_form_error
      render :action => 'edit'
    end
  end



  ### checking whether email is already present in the database
  def check_email
    @user_email = Profile.find_by_email(params[:new_profile][:email])
    if @user_email
      @user_email = false
    else
      @user_email = true
    end
    respond_to do |format|
      format.json do
        render :json => @user_email
      end
    end
  end

  ## checking whether username is already present in the database
  def check_username
    @user_name = Profile.find_by_username(params[:new_profile][:username])
    if @user_name
      @user_name = false
    else
      @user_name = true
    end
    respond_to do |format|
      format.json do
        render :json => @user_name
      end
    end
  end

  def failure
    session[:user_id] = nil
    session[:login_type]=nil
    render :text => "You've logged out!"
  end

  private 

  def set_console_section
    @console_section = :profile
  end

end
