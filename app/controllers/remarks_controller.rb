class RemarksController < ApplicationController
  before_filter :require_profile
  before_filter :load_project
  before_filter :load_entry

  def create
    @blog_entry.remarks.create(params[:remark].merge(:profile => current_profile))
    redirect_to project_url(@blog_entry.project, :anchor => "blog")
    @follow=@project.blog_comments_followers
    @prof=@project.profiles
    followers_blog_comments_mails= @follow - @prof
    if  !@project.originators.empty?&& !@project.blog_comments_originator.empty?
      @project.blog_comments_originator.each do |user|
        Mailer.send_later(:deliver_add_blog_comment_to_originator,@project,current_profile,user.username,user.email)
      end
    end
    if  !@project.members.empty?&& !@project.blog_comments_collaborators.empty?
      @project.blog_comments_collaborators.each do |user|
        Mailer.send_later(:deliver_add_blog_comment_to_collaborator,@project,current_profile,user.username,user.email)
      end
    end
    if !@project.followers.empty?&& !@project.blog_comments_followers.empty?
      followers_blog_comments_mails.each do |user|
        Mailer.send_later(:deliver_add_blog_comment_to_followers,@project,current_profile,user.username,user.email)
      end
    end
  end

  private

  def load_entry
    @blog_entry = @project.blog_entries.find(params[:blog_entry_id])
  end
end
