class DashboardController < ApplicationController
  before_filter :require_profile
  before_filter :add_console

  def show
p current_profile
    @console_section = :dashboard
    @projects = current_profile.projects_by_type
    puts "--------sdjhvsdjbvbvjdsbvjdsbjvb--------------"
   p @projects
   puts "--------sdjhvsdjbvbvjdsbvjdsbjvb--------------"
  
     @activities = Activity.for_projects( Profile.current_my_projects(current_profile),current_profile.created_at).latest(50)
    
    @requests=Project.request(current_profile)
     @new_activities=Array.new
     @activities.each do |activity|
      @new_activities.push(activity)
    end
    
    @activity = @new_activities.paginate :page => params[:page], :per_page => 32

   end

  [:inbox, :network, :store, :settings].each do |section|
    define_method section do
      @console_section = section
      render
    end
  end
end
