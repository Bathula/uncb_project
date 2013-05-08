class LikesController < ApplicationController
  before_filter :require_profile
  before_filter :load_project

  def create
    @project.likes.create(:profile => current_profile)
    redirect_to @project    
    if !@project.originators.empty? && !@project.likes_originator.empty?
      @project.likes_originator.each do |user|
        Mailer.send_later(:deliver_likes_to_originator,@project,current_profile,user.display_name,[user.email]-[current_profile.email])
      end
    end
    if !@project.members.empty? && !@project.likes_collaborators.empty?
           @project.likes_collaborators.each do |user|
               Mailer.send_later(:deliver_likes_to_collaborators,@project,current_profile,user.display_name,[user.email]-[current_profile.email])
      end
    end
  end
  
  def destroy
    like = @project.likes.find(params[:id])

    if like.profile == current_profile
      like.destroy
      redirect_to @project
    else
      render :status => 401, :nothing => true
    end
  end
end
