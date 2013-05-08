class MembersController < ApplicationController
  before_filter :require_profile
  before_filter :load_project
  before_filter :check_ownership
  before_filter :load_profile, :only => :create
  before_filter :load_membership, :only => :destroy
  before_filter :load_membership_for_promote, :only => :promote
  before_filter :add_console
  before_filter :set_console_section
  before_filter :store_location, :only => :index

  def index
  
  end

  def create
    membership = @project.add_participant(@profile)
    respond_to do |format|
      format.html { redirect_to project_members_url(@project) }
      Mailer.send_later(:deliver_accept_project_to_user,@profile,current_profile,@project)
      unless @project.members.empty?
        @project.members.each do |user|
        Mailer.send_later(:deliver_member_acceptance_to_collaborators,@project,@profile,user.display_name,user.email)
      end
      end
      format.js do
        if membership.valid?
          render :partial => "member", :locals => { :member => @profile, :project => @project }
        else
          render :nothing => true
        end
      end
    end
  end


  def destroy   
  if !params[:follower]
    Mailer.deliver_deny_to_user(@project,current_profile,@membership)
    @membership.destroy
    redirect_to project_members_url(@project)
  else
  @follower = Interest.follower(@project.id,params[:id])
  @follower.destroy
    redirect_to project_members_url(@project)
  end
  end

  def promote
    @membership.update_attribute(:originator, true)
    redirect_to project_members_url(@project)
  end

  private

  def load_profile
    @profile = if params[:display_name]
      Profile.find_by_display_name(params[:display_name])
    else
      Profile.find(params[:member][:profile_id])
    end
  end

  def load_membership
    if !params[:follower] && !params[:remove]
     @membership = MembershipRequest.find_by_project_id_and_profile_id!(@project.id, params[:id])

    elsif params[:remove]
        @membership = Membership.find_by_project_id_and_profile_id!(@project.id, params[:id])
    end
    end

  def load_membership_for_promote
    if !params[:follower]
     @membership = Membership.find_by_project_id_and_profile_id!(@project.id, params[:id])
    end
    end

  def set_console_section
    @console_section = :projects
  end
end
