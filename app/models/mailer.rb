class Mailer < ActionMailer::Base
  FROM_NAME = "Original Projects"
  FROM_EMAIL = "no-reply@originalprojects.com"
  
  def password_reset(profile)
    setup_mail

    recipients  profile.email
    subject     "Your Original Projects Password"
    body        :password_reset_url => password_url(profile.perishable_token)
  end

  def user_specified_message(message)
    setup_mail

    @from = "#{message.from.display_name} <#{FROM_EMAIL}>"
    reply_to    message.from.email    
    recipients  message.to.email
    subject     message.subject
    body        :sender_name => message.from.display_name, :message => message.body
  end

  def invite(invite)
    setup_mail

    @subject = "You've signed up for Original Projects"
    @body = { :invite => invite, :invite_request => invite.invite_request }
    @recipients = invite.invite_request.email_address
  end

  def profile(profile)
    setup_mail
    @subject = "You've signed up for Original Projects"
    @body = { :profile => profile,:display_name=> profile.display_name }
    @recipients = profile.email
    content_type "text/html"
  end
  
  def activation_link(profile)
    setup_mail    
    @subject = "You've asked up Original Projects to resend activation link"
    @body = { :profile => profile,:display_name=> profile.display_name }
    @recipients = profile.email
  end

  def feedback(info)
    setup_mail

    reply_to info[:email]
    recipients  "nathan@originalprojects.com,pradeep.narava@gmail.com"
    subject     "[OP] Feedback Received"
    body        :info => info
  end


    def developers(info)
    setup_mail

    reply_to info[:email]
    recipients  "nathan@originalprojects.com,pradeep.narava@gmail.com"
    subject     "[OP] Developers"
    body        :info => info
  end



  
  def setup_mail
    @from = "#{FROM_NAME} <#{FROM_EMAIL}>" 
  end
  ## Notifications
 def follows_original_project(project,profile,user_display_name,email)
     setup_mail
    @subject = "#{profile.display_name} is now following #{project.title} on Original Projects"
    @body = {:user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project),:project_followers_url=> followers_url(project)}
       @recipients = email
    #@recipients = project.followups.collect(&:email)
    content_type "text/html"
 end



   def follows_project_to_originator(project,profile,user_display_name,email)
    setup_mail
    @subject = "#{profile.display_name} is now following #{project.title} on Original Projects"
    @body = {:user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project),:project_followers_url=> followers_url(project)}
       @recipients = email
    #@recipients = project.followups.collect(&:email)
    content_type "text/html"
  end
  def follows_project_to_collaborators(project,profile,user_display_name,email)
    setup_mail
    @subject = "#{profile.display_name} is now following #{project.title} on Original Projects"
    @body = {:user_display_name => user_display_name, :display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project),:project_followers_url=> followers_url(project) }
     @recipients = email
    #@recipients = project.followups_members.collect(&:email)
    content_type "text/html"
  end
  
  def join_project_to_originator(project,profile,user_username,email)
    setup_mail
    @subject = "#{profile.display_name} requested to join #{project.title} on Original Projects"
    @body = { :user_username => user_username, :username => profile.username,:project_name => project.title ,:username_profile_url => profile_url(profile),:project_url => project_url(project),:like_to_join => MembershipRequest.find(:all,:conditions=>['profile_id=? AND project_id=?',profile.id,project.id]).collect(&:like_to_join),:project => project,:profile => profile}
        @recipients = email
    #@recipients = project.join_projects.collect(&:email)
    content_type "text/html"
  end

  def join_project_member_to_originator(project,profile,user_display_name,email)
    setup_mail
    @subject = "#{profile.display_name} joined #{project.title} on Original Projects"
    @body = { :user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project),:like_to_join =>Membership.find(:all,:conditions=>['profile_id=? AND project_id=?',profile.id,project.id]).collect(&:like_to_join),:project => project,:profile => profile,:project_team_url =>  team_url(project)}
    @recipients = email
    #@recipients = project.join_projects.collect(&:email)
    content_type "text/html"
  end

    def join_project_member_to_collaborators(project,profile,user_display_name,email)
    setup_mail
    @subject = "#{profile.display_name} joined #{project.title} on Original Projects"
    @body = { :user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project),:like_to_join => profile.memberships.collect(&:like_to_join),:project => project,:profile => profile,:project_team_url =>  team_url(project)}
    @recipients = email
    #@recipients = project.join_projects.collect(&:email)
    content_type "text/html"
  end


  def likes_to_originator(project,profile,user_display_name,email)
    setup_mail
    @subject = "#{profile.display_name} likes #{project.title} on Original Projects"
    @body = { :user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project) }
     @recipients = email
    #@recipients = project.likes_originator.collect(&:email)
    content_type "text/html"
  end

 

  def likes_to_collaborators(project,profile,user_display_name,email)
    setup_mail
    @subject = "#{profile.display_name} likes #{project.title} on Original Projects"
    @body = { :user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project)}
    @recipients = email
    #@recipients = project.likes_collaborators.collect(&:email)
    content_type "text/html"
  end

  def comments_to_originator(current_profile,project,user_display_name,email)
    setup_mail
     @subject = "Comment left on #{project.title} on Original Projects"
    @body = { :user_display_name => user_display_name,:display_name => current_profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(current_profile),:project_url => project_url(project),:project_comment_url =>  comments_url(project) }
    @recipients = email
    #@recipients = project.comments_originator.collect(&:email)
    content_type "text/html"
  end
 
  def comments_to_collaborator(project,profile,user_display_name,email)
    setup_mail
    @subject = "Comment left on #{project.title} on Original Projects"
    @body = { :user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project),:project_comment_url =>  comments_url(project) }
    @recipients =  email
     #@recipients =  project.comments_collaborators.collect(&:email)
    content_type "text/html"
  end

  def comments_to_followers(project,profile,user_display_name,email)
    setup_mail   
    @subject = "Comment left on #{project.title}on Original Projects"
    @body = { :user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project),:project_comment_url =>  comments_url(project) }
    @recipients =  email
#    @recipients =  project.comments_followers.collect(&:email)-project.profiles.collect(&:email)
    content_type "text/html"
  end

  def accept_project_to_user(profile,org_profile,project)
    setup_mail
    @subject = "Congratulations! Your request to join #{project.title} has been approved"
    @body = {:current_profile => org_profile.display_name,:current_profile_url=> profile_url(org_profile),:username => profile.username,:project_name => project.title ,:username_profile_url => profile_url(profile),:project_url => project_url(project) }
    @recipients = profile.email
    content_type "text/html"
  end
  def member_acceptance_to_collaborators(project,profile,user_display_name,email)
    setup_mail
    @subject = "#{profile.display_name} joined #{project.title} on Original Projects"
    @body = {:user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project),:project_team_url =>  team_url(project)}
    @recipients = email
    #@recipients = project.members.collect(&:email)
    content_type "text/html"

  end

  def deny_to_user(project,profile,requester)
    setup_mail
    @subject = "Your request to join #{project.title}"
    @body = { :requester_name => requester.profile.display_name, :username => profile.display_name,:project_name => project.title,:username_profile_url => profile_url(profile),:project_url => project_url(project)}
    @recipients = requester.profile.email
    content_type "text/html"
  end

 


  def add_entry_to_blog_collaborator(project,profile,user_display_name,email)
    setup_mail
    @subject = "Blog entry posted for #{project.title} on Original Projects"
    @body = { :user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title,:display_name_profile_url => profile_url(profile),:project_url => project_url(project),:project_blog_url => blog_url(project)}
   @recipients = email
    @recipients = project.blog_post_collaborators.collect(&:email)
    content_type "text/html"
  end

  def add_entry_to_blog_followers(project,profile,user_display_name,email)
    setup_mail
    @subject = "Blog entry posted for #{project.title} on Original Projects"
    @body = { :user_display_name => user_display_name,:display_name => profile.display_name,:project_name => project.title ,:display_name_profile_url => profile_url(profile),:project_url => project_url(project),:project_blog_url => blog_url(project)}
        @recipients = email
#    @recipients = project.blog_post_followers.collect(&:email)-project.profiles.collect(&:email)
    content_type "text/html"

  end


  def add_blog_comment_to_originator(project,profile,user_username,email)
    setup_mail
    @subject = "#{profile.username} commented on #{project.originators.collect(&:username)} blog entry for #{project.title} on Original Projects. "
    @body = {:user_username => user_username,:orig_username => project.originators.collect(&:username),:orig_username_profile_url => profile_url(project.originators),:username => profile.username,:project_name => project.title ,:username_profile_url => profile_url(profile),:project_url => project_url(project),:project_blog_comment_url =>  blog_url(project)}
     @recipients = email
     content_type "text/html"
  end

  def add_blog_comment_to_collaborator(project,profile,user_username,email)
    setup_mail
      @subject = "#{profile.username} commented on #{project.originators.collect(&:username)} blog entry for #{project.title} on Original Projects. "
      @body = {:user_username => user_username,:orig_username => project.originators.collect(&:username),:orig_username_profile_url => profile_url(project.originators),:username => profile.username,:project_name => project.title ,:username_profile_url => profile_url(profile),:project_url => project_url(project),:project_blog_comment_url =>  blog_url(project)}
      @recipients = email
       content_type "text/html"
  end

  def add_blog_comment_to_followers(project,profile,user_username,email)
    setup_mail
       @subject = "#{profile.username} commented on #{project.originators.collect(&:username)} blog entry for #{project.title} on Original Projects. "
       @body = { :user_username => user_username,:orig_username => project.originators.collect(&:username),:orig_username_profile_url => profile_url(project.originators),:username => profile.username,:project_name => project.title ,:username_profile_url => profile_url(profile),:project_url => project_url(project),:project_blog_comment_url =>  blog_url(project)}
       @recipients = email
       content_type "text/html"
  end


  def mail_to_linkedin_or_facebook_connect(profile)
    setup_mail
    @subject = "You've signed up for Original Projects"
    @body = { :profile => profile,:display_name=> profile.display_name }
    @recipients = profile.email
    content_type "text/html"
  end

  def mail_to_specified_user_message(profile,current_profile,message)
    setup_mail
    @subject = "Message from #{current_profile.display_name}"
    @body = { :display_name=> current_profile.display_name,:message=>message,:recipent=>profile.display_name,:display_name_profile_url => profile_url(current_profile) }
    @recipients = profile.email
    content_type "text/html"
  end

 def email_send_to_network_member(current_profile,recipent_profile,message,message_id)
    setup_mail
    @subject = "#{current_profile.display_name} sent you a message on Original Projects"
    @body = { :display_name=> current_profile.display_name,:message=>message,:recipent_name=>recipent_profile.display_name,:display_name_profile_url => profile_url(current_profile),:message_id => message_id}
    @recipients = recipent_profile.email
    content_type "text/html"
  end

 def email_send_to_project_followers(recipent_profile,project)
    setup_mail
    @subject = "#{project.title} has been deleted completley on Original Projects"
    @body = { :recipent_name=>recipent_profile.display_name,:project => project.title}
    @recipients = recipent_profile.email
    content_type "text/html"
  end

 def email_send_to_project_collabrators(recipent_profile,project)
    setup_mail
    @subject = "#{project.title} has been deleted completley on Original Projects"
    @body = { :recipent_name=>recipent_profile.display_name,:project => project.title}
    @recipients = recipent_profile.email
    content_type "text/html"
  end

end