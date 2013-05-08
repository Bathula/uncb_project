class AccessesController < ApplicationController
  before_filter :require_profile, :except => [ :index, :show,:image_uploadify,:email_linkedin,:fb_with_op,:delete_profile_account,:delete_all_from_account_completely ]
  #  before_filter :load_project, :only => [ :show, :edit, :update, :follow, :join,:join_new,:new ]
  #before_filter :check_ownership, :only => [ :edit, :update ]
  before_filter :add_console, :except => [ :index, :show ]
  before_filter :set_console_section
  before_filter :store_location




  # GET /accesses/new
  # GET /accesses/new.xml
  def new
    @current_projects=current_profile.projects
    @projects_originated = current_profile.originated_projects
    @projects = current_profile.followed_projects - @current_projects
    @projects_members = current_profile.member_projects
  end

  def originated
    @access = Membership.find(params[:id])
  end

  def originated_open
    @access = Membership.find(params[:id])
  end

  def originated_update
    @access =Membership.find(params[:id])
    respond_to do |format|
      if @access.update_attributes(params[:access])
        add_notice 'Settings were successfully updated.'
        format.html { redirect_to(new_access_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @access.errors, :status => :unprocessable_entity }
      end
    end
  end

  def follow_open
    @access = Interest.find(params[:id])
  end
  
  def follow_open_update
    @access = Interest.find(params[:id])
    respond_to do |format|
      if @access.update_attributes(params[:access])
        add_notice 'Settings were successfully updated.'
        format.html { redirect_to(new_access_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @access.errors, :status => :unprocessable_entity }
      end
    end
  end

  def follow_update
    @access = Interest.find(params[:id])
    respond_to do |format|
      if @access.update_attributes(params[:access])
        add_notice 'Settings were successfully updated.'
        format.html { redirect_to(new_access_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @access.errors, :status => :unprocessable_entity }
      end
    end
  end

  def message_settings
   
      @message_settings = MessageSetting.find_by_profile_id(params[:id])
     end


  def message_settings_update
  
    respond_to do |format|
      if current_profile.message_setting.update_attributes(:messages_sent=> params[:message_settings][:messages_sent])
        add_notice 'Settings were successfully updated.'
        format.html { redirect_to(new_access_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @access.errors, :status => :unprocessable_entity }
      end
    end





 # if   current_profile.message_setting.update_attributes(:messages_sent=> params[:access][:messages_sent])

    end



  def email_linkedin
    current_profile.update_attributes(:member_id => request.cookies['window_name'],:network => "linkedin")
    add_notice = "Succesfully added to OP account"
      @linkedinlogged="linkedin"
redirect_to password_accesses_url
  end

  
  def fb_with_op
    current_profile.update_attributes(:facebook_id =>facebook_session.user.id,:session_key=>facebook_session.session_key)
 add_notice = "Succesfully added to OP account"
 @facebooklogged="facebook"
redirect_to password_accesses_url
  end

     def fb_disconnect
       
      current_profile.update_attributes(:facebook_id =>"",:session_key=>"")
      session[:user_id]=nil
   session[:login_type]=nil
   session[:fb_session]=nil
   if !current_profile_session.nil?
   current_profile_session.destroy
   end
clear_session
      redirect_to password_accesses_url
    end

       def linkedin_disconnect
      current_profile.update_attributes(:member_id =>"",:network=>"")
      redirect_to password_accesses_url
    end


  def password
    render
  end
  
  def password_update
  
       if session[:login_type]=='facebook'
      current_profile = Profile.find_by_facebook_id(session[:user_id])
    else
      current_profile = @profile
    end

 


   
    if current_profile.update_attributes(params[:profile])
      add_notice 'Your account has been successfully updated'
      redirect_to password_accesses_path

      ## unsubscribing from mailchimp list
#     if  params[:profile][:newsletter]=="0"
#             h = Hominid::Base.new({:api_key => 'c0d8e1a5fd6db89021120c3c4c79125d-us1'})
#             list = h.lists.find {|list| list["name"] == "original projects test" }
#             h.unsubscribe(list["id"], params[:profile][:email])
#             puts "unsubscribe"
#     else
#
#       h = Hominid::API.new({:api_key => 'c0d8e1a5fd6db89021120c3c4c79125d-us1'})
#             list = h.lists.find {|list| list["name"] == "original projects test" }
#             h.subscribe(list["id"], params[:profile][:email])
#             puts "subscribe"
#
#               end


    else
       if session[:login_type]=='facebook'
      current_profile = Profile.find_by_facebook_id(session[:user_id])
       end
      render :action => 'password'
    end
  
  end

  def update
    if current_profile.update_attributes(params[:profile])
     
      add_notice 'Your account has been successfully updated'
   
      redirect_to my_settings_url
    else
      add_form_error
      render :action => 'edit'
    end
  end
  
  def collaborators
    @access = Membership.find(params[:id])
  end

  def collaborators_open
    @access = Membership.find(params[:id])
  end

  def collaborators_open_update
    @access = Membership.find(params[:id])

    respond_to do |format|
      if @access.update_attributes(params[:access])
        add_notice 'Settings were successfully updated.'
        format.html { redirect_to(new_access_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "collaborators" }
        format.xml  { render :xml => @access.errors, :status => :unprocessable_entity }
      end
    end
  end
  


  def collaborator_update
    @access = Membership.find(params[:id])
    respond_to do |format|
      if @access.update_attributes(params[:access])
        add_notice 'Settings were successfully updated.'
        format.html { redirect_to(new_access_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "collaborators" }
        format.xml  { render :xml => @access.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /accesses/1
  # DELETE /accesses/1.xml
  def destroy
    @access = Access.find(params[:id])
    @access.destroy

    respond_to do |format|
      format.html { redirect_to(accesses_url) }
      format.xml  { head :ok }
    end
  end

  def account_settings
    render
  end

  def delete_profile_account

  end

  def delete_account
    if  params[:profile_session][:email]      
         current = Profile.find_by_email(params[:profile_session][:email])
        current_profile_session = ProfileSession.new(params[:profile_session])      
       if current_profile_session.save
         add_notice "You have been successfully deleted your account from Original Projects."
 redirect_to logout_url
         delete_all_from_account_completely
       
       else
       @errors = ['Invalid password']
         render :action=> :delete_profile_account
  
    end
  end
  end


  private

 def delete_all_from_account_completely

    current_profile.originated_projects.each do |project|

      project.followers.each do |@follower|

     
      Mailer.send_later(:deliver_email_send_to_project_followers,@follower,project)
      end
      project.members.each do |@collabrator|
     
       Mailer.send_later(:deliver_email_send_to_project_collabrators,@collabrator,project)
      end
      Project.find(project.id).destroy
    end
Membership.find(:all,:conditions=>{:profile_id=>current_profile.id}).each do |profile|
 Membership.find(profile.id).destroy
 end
MembershipRequest.find(:all,:conditions=>{:profile_id=>current_profile.id}).each do |profile|
 MembershipRequest.find(profile.id).destroy
 end
   Interest.find(:all,:conditions=>{:profile_id => current_profile.id}).each do |profile|
   Interest.find(profile.id).destroy
   end

Network.find_all_by_member_id(current_profile.id).each do |member|
  member.destroy

end
current_profile.originated_services.each do |service|
Service.find(service.id).destroy
end




   current_profile.destroy


   end



  def set_console_section
    @console_section = :settings
  end

end
