class CommentsController < ApplicationController
  before_filter :require_profile
  before_filter :load_project

  def create
    @project.comments.create(params[:comment].merge(:profile => current_profile))
    redirect_to project_url(@project, :anchor => "comments")
       if !@project.originators.empty?&& !@project.comments_originator.empty?
      @project.comments_originator.each do |user|
        Mailer.send_later(:deliver_comments_to_originator,current_profile,@project,user.display_name,[user.email]-[current_profile.email])
      end
    end
    if !@project.members.empty? && !@project.comments_collaborators.empty?
      @project.comments_collaborators.each do |user|
        Mailer.send_later(:deliver_comments_to_collaborator,@project,current_profile,user.display_name,[user.email]-[current_profile.email])
      end
    end
    if  !@project.followers.empty? && !@project.comments_followers.empty?
       @follow=@project.comments_followers
       @prof=@project.profiles
       followers_mails= @follow - @prof
      followers_mails.each do |user|
        Mailer.send_later(:deliver_comments_to_followers,@project,current_profile,user.display_name,[user.email]-[current_profile.email])
      end
    end
  end
end
