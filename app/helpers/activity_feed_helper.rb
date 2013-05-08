module ActivityFeedHelper
  def activity_to_html(activity)
    output = case activity.subject
    when Project then new_project_activity(activity.profile, activity.subject)
    when Membership then new_membership_activity(activity.profile, activity.project, activity.subject)
    when Interest then new_follower_activity(activity.profile, activity.project)
    when Attachment then new_attachment_activity(activity.subject, activity)
    when Comment then new_comment_activity(activity.profile, activity.project)
    when BlogEntry then new_blog_entry_activity(activity.profile, activity.project)
    when Remark then new_remark_activity(activity.profile, activity.project, activity.subject)
    when Profile then new_profile_activity(activity.profile, activity.project)
    when Like then new_like_activity(activity.profile, activity.project)
    when Service then new_service_activity(activity.profile, activity)
    when MembershipRequest then new_membership_request_activity(activity.profile, activity.project)
    when nil then
      activity.destroy
      "This activity has been removed"
    end

    output
  end

  def  new_profile_activity(profile,project)

    unless project.nil?
      if project.public?
        "#{link_to_profile(profile)} is now following #{link_to_project(project)}."
      else
        "#{link_to_profile(profile)} is now following #{link_to_project(project)}(private)."
      end
    end
  end

  def new_service_activity(profile,activity)
   
        "#{link_to_profile(profile)}  set up  #{link_to_service(activity.subject)}  as a new service."
  end


  def new_project_activity(profile, project)
    if profile.present?
      "#{link_to_profile(profile)} created a project called " +
        "#{link_to_project(project)}."
    else
      "A project called #{link_to_project(project)} was created."
    end
  end


  def new_like_activity(profile,project)
    "#{link_to_profile(profile)} likes #{link_to_project(project)}."
  end


  def new_membership_activity(profile, project, membership)
    output = [link_to_profile(profile)]
    if membership.originator?
      output << "is now an originator of"
    else
      output << "is now a member of"
    end
    output << link_to_project(project)
    output.join(" ") + "."
  end

  def new_membership_request_activity(profile,project)
    "#{link_to_profile(profile)} #{link_to"requested", project_members_path(project)} to join  #{link_to_project(project)}."
  end



  def new_follower_activity(profile, project)
    if project.public?
      "#{link_to_profile(profile)} is now following #{link_to_project(project)}."
    else
      "#{link_to_profile(profile)} is now following #{link_to_project(project)}(private)."
    end
  end

  def new_attachment_activity(attachment, activity)
    attachable_name = if attachment.attachable.respond_to?(:name)
                      then attachment.attachable.name
                      else attachment.attachable.title
                      end rescue nil

    output = ""
    if attachable_name
      output += "A new #{attachment.class.to_s.downcase} has been added to "
      output += case attachment.attachable
                when Project then link_to_project(attachment.attachable)
                when Profile then link_to_profile(attachment.attachable)
                else link_to(attachable_name, attachment.attachable)
                end
    end
    output += "."
    output
  end

  def new_comment_activity(profile, project)
    "#{link_to_profile(profile)} left a comment on #{link_to project.title, project_url(:id => project.to_param, :anchor => 'comments')}."
  end

  def new_blog_entry_activity(profile, project)
    "#{link_to_profile(profile)} posted a blog entry on #{link_to project.title, project_url(:id => project.to_param, :anchor => 'blog')}."
  end

  def new_remark_activity(profile, project, remark)
    "#{link_to_profile(profile)} commented on #{link_to_profile(remark.blog_entry.profile)}'s blog entry for #{link_to project.title, project_url(:id => project.to_param, :anchor => 'blog')}."
  end
 

  def activity_for_profile(activity)
    text =  case activity.subject
    when Project then
      "Started a new project called #{link_to_project(activity.subject)}."
    when Membership then
      if activity.subject.originator?
        "Became an originator of #{link_to_project(activity.project)}."
      else
        "Became a member of #{link_to_project(activity.project)}."
      end
    when Interest then
     if  activity.project.public?
      "Started following #{link_to_project(activity.project)}."
     else
      "Started following #{link_to_project(activity.project)}(private)."
      end
    when Comment then
      "Commented on #{link_to_project(activity.project)}."
    when BlogEntry then
      "Posted a blog entry on #{link_to_project(activity.project)}."
    when Remark then
      "Commented on a blog entry for #{link_to_project(activity.project)}."
    when Profile then
      if !activity.project.nil? && activity.project.public?
        "You are now following #{link_to_project(activity.project)}."
      else
        "You are now following #{link_to_project(activity.project)}(private)."
      end
    when Like then
      "Likes #{link_to_project(activity.project)}."
    when Service then
      
      "Setup #{link_to_service(activity.subject)}"

      when MembershipRequest then
      "Requested #{link_to_project(activity.project)}."
    when nil then ""
    end

    content_tag(:li, text + %Q[<br /><span class="gray">#{activity.created_at.strftime("%B %e, %Y")}</span>])
  end
end
