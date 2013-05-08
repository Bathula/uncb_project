class MembershipRequestsController < ApplicationController
  before_filter :require_profile
  before_filter :load_project
  before_filter :check_ownership, :only => :destroy

  #Popup box for Request JOIN  link
  def new
    @mr = @project.membership_requests.build
    respond_to do |format|
      format.html
      format.js {
        render :partial => "form",:locals => {:return_to => params[:return_to]}
      }
    end
  end

  def join
    @mr = @project.memberships.build
    respond_to do |format|
      format.html
      format.js {
        render :partial => "join_form",:locals => {:return_to => params[:return_to]}
      }
    end
  end

  def join_create
    @mr = @project.memberships.build(params[:message])
    @mr.profile_id=current_profile.id
    @return_to = params[:return_to]
    if @mr.valid? and verify_recaptcha(:model => @mr,:message => 'Its error with ReCaptcha')
      @mr.save
      add_notice "You have now joined #{@project.title}.  You are part of the team!"
      redirect_to (@return_to)

     @project.originators.each do |user|
      @message= Message.create(:from_id=> current_profile.id,:to_id => user.id,:subject=>"Join This Project",:body=>params[:message][:like_to_join])
     @message_copies =MessageCopy.create(:recipient_id=>user.id,:message_id=>@message)
      end
          if !@project.originators.empty? && !@project.open_originator.empty?
        @project.open_originator.each do |user|
        Mailer.send_later(:deliver_join_project_member_to_originator,@project,current_profile,user.display_name,user.email)
            end
          end
      if  !@project.members.empty? && !@project.open_members.collect(&:email).empty?
       @project.open_members.each do |user|
      Mailer.send_later(:deliver_join_project_member_to_collaborators,@project,current_profile,user.display_name,user.email)
            end
    end
     # end
    else
      add_error @mr.errors.full_messages.join("; "), :now => true
      render :action => "join"
    end
  end

  def create_member
    @mr = @project.membership_requests.build(params[:message])
    @mr.profile_id=current_profile.id
    @return_to = params[:return_to]
    if @mr.valid? and verify_recaptcha(:model => @mr,:message => 'Its error with ReCaptcha')
      @mr.save
      add_notice "You request to join #{@project.title} has been sent!"
      redirect_to (@return_to)
      @project.originators.each do |user|
      @message= Message.create(:from_id=> current_profile.id,:to_id => user.id,:subject=>"Request To Join",:body=>params[:message][:like_to_join])
       @message_copies =MessageCopy.create(:recipient_id=>user.id,:message_id=>@message)
      end
        if !@project.originators.empty? && !@project.join_projects_orig.empty?
        @project.join_projects_orig.each do |user|
        Mailer.send_later(:deliver_join_project_to_originator,@project,current_profile,user.username,user.email)
      end
      end
    else
      add_error @mr.errors.full_messages.join("; "), :now => true
      render :action => "new"
    end
  end

  

  def destroy
        @membership_requests = @project.membership_requests.find(params[:id])
     Mailer.deliver_deny_to_user(@project,current_profile,@membership_requests)
    @project.membership_requests.find(params[:id]).destroy
    redirect_to project_members_url(@project)
  end
  
end
