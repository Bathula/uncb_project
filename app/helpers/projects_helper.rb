module ProjectsHelper
  def originators(project)
    output = "#{pluralize_by_count("Originator", project.originators.count)}: "
    output << project.originators.map { |profile|
      if profile == current_profile then "YOU" else profile.name end
    }.to_sentence
    output
  end

  def public
  find(:all,:conditions=>["public=?",'1']).collect(&:id)
  end

  def follow_join_and_like_project_links(tag, project)
    output = []
    if current_profile.is_involved?(project) ||current_profile.is_following?(project)
      
      output << "You Are Participating in This Project"
      
      else
      if current_profile.is_following?(project)
        output << "You Are Following"
      else
        output << link_to("Follow This Project", follow_project_path(project), :method => :post)
      end

      if project.has_open_membership?
        output << link_to("Join This Project", join_membership_request_path(project, :return_to => project_path(project)), :rel => "facebox")
      elsif project.has_invite_membership?
        if current_profile.requested_membership?(project)
          output << "Pending Approval"
        else
          output << link_to("Request To Join", my_membership_requests_path(project, :return_to => project_path(project)), :rel => "facebox")
        end
      end
    end

    like = current_profile.like_for(project)
    like_count = project.likes.count
    like_count_text = "(#{pluralize(like_count, "Like")})" if like_count > 0

    if like
      output << link_to("Unlike #{like_count_text}", project_like_url(project, like), :method => :delete)
    else
      output << link_to("I Like This #{like_count_text}", project_likes_url(project), :method => :post)
    end

    output.map { |link| content_tag(tag, link) }.join
  end
# video link info
  
  require "net/http"
require "uri"
require 'json'

# We need to extract the video ID    
YOUTUBE_RE = /^(https?:\/\/[^\/]*youtube.com\/)watch\?[^\/]*v=([\w-]+).*/i
VIMEO_RE   = /^(https?:\/\/[^\/]*vimeo.com\/)([\w-]+).*/i

def read(url)
  case url
  when YOUTUBE_RE
    apiUrl = 'http://gdata.youtube.com/feeds/api/videos/' + $2 + '?alt=json'
    video  = http_request(apiUrl)
  
    { :url           => url,
      :title         => video['entry']['title']['$t'],
      :description   => video['entry']['media$group']['media$description']['$t'],
      :thumbnail_url => video['entry']['media$group']['media$thumbnail'][1]['url'],
    }
  when VIMEO_RE
    apiUrl = 'http://vimeo.com/api/v2/video/' + $2 + '.json'
    video  = http_request(apiUrl)  
    { :url            => url,
      :title          => video[0]['title'],
      :description    => video[0]['caption'],
      :thumbnail_url => video[0]['thumbnail_small'],
    }
  end
end

def http_request(url)
  response = Net::HTTP.get_response(URI.parse(url)).body
  response = JSON.parse(response) rescue response
end

#  end video link info

  def join_project_link(text, project)
    if project.has_open_membership?
      if !logged_in?
        link_to text, login_path
      elsif !current_profile.is_involved?(project)
        link_to text, join_project_path(project), :method => :post
      end
    end
  end
end
