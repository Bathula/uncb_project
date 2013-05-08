class ProjectsController < ApplicationController
  uses_tiny_mce(:options => AppConfig.default_mce_options, :only => [:new, :edit, :index, :create])
  before_filter :require_profile, :except => [ :index, :show, :image_uploadify,:edit,:edit_images,:media,:comments,:wanted,:blog,:followers,:team ]
  before_filter :load_project, :only => [ :show, :edit, :update, :follow, :join,:join_new,:edit_images ,:media,:blog,:comments,:wanted,:team,:followers]
  before_filter :check_ownership, :only => [ :edit, :update]
 # before_filter :check_membership, :only => [:update,:edit_images]
  before_filter :add_console, :except => [ :index, :show,:media,:blog,:comments,:wanted,:team,:followers]
  before_filter :set_console_section, :except => [ :index, :show ]
  #before_filter :store_location, :only => [ :index, :show ]
  
 # skip_before_filter :verify_authenticity_token









  def index
    @section = "projects"
    sort = case params['sort']
  when ""  then "title ASC"
    when ""  then "rating_cache DESC"
    when "a-z"  then "title ASC"
    when "z-a"  then "title DESC"
    when "location"   then "location ASC"
    when "highestrated"   then "rating_cache DESC"
    when "mostrated"   then "rating_count_cache DESC"
    when "highestpro"   then "rating_cache_pro DESC"
    when "mostpro"   then "rating_count_cache_pro DESC"
    when "category" then "projectcategory_id ASC, title ASC"
                     
    end
    if !params['sort']
      puts"111111111111111111"
      #sort = "rating_cache DESC,rating_count_cache DESC"
      sort = "rating_cache DESC"
     #sort= "title ASC"
    end
    page = params[:page] || 1
    category = Projectcategory.find_by_id(params[:category])
    if params[:category] == "All" || !params[:category]||params[:category]==""
    	@projects = Project.visible.paginate :page => params[:page], :order => sort, :per_page => 25
    else
    	@projects = Project.visible.category(category.id).paginate :page => params[:page], :order => "rating_cache DESC", :per_page => 25
    end
    @categories=Projectcategory.all
  end

  def show
       respond_to do |format|
      format.html do
        @sidebar = { :partial => "projects/sidebar", :locals => { :project => @project } }

      end
#      format.atom do
#        @activities = Activity.for_project(@project).latest(10)
#      end
    end
  end

  def media

    respond_to do |format|
      format.html do
        @sidebar = { :partial => "projects/sidebar", :locals => { :project => @project } }
      end
      format.atom do
        @activities = Activity.for_project(@project).latest(10)
      end
    end
    render :action=>"show"
    
  end
  
   

  def wanted

  respond_to do |format|
      format.html do
        @sidebar = { :partial => "projects/sidebar", :locals => { :project => @project } }
      end
      format.atom do
        @activities = Activity.for_project(@project).latest(10)
      end
    end
    render :action=>"show"

  end
 


  def blog
       
respond_to do |format|
      format.html do
        @sidebar = { :partial => "projects/sidebar", :locals => { :project => @project } }
      end
      format.atom do
        @activities = Activity.for_project(@project).latest(10)
      end
    end
    render :action=>"show"

  end

  def team
respond_to do |format|
      format.html do
        @sidebar = { :partial => "projects/sidebar", :locals => { :project => @project } }
      end
      format.atom do
        @activities = Activity.for_project(@project).latest(10)
      end
    end
    @members=@project.members.paginate :page=>params[:page],:per_page=>5
    render :action=>"show"

  end

  def followers
respond_to do |format|
      format.html do
        @sidebar = { :partial => "projects/sidebar", :locals => { :project => @project } }
      end
      format.atom do
        @activities = Activity.for_project(@project).latest(10)
      end
    end
    @followers=@project.non_member_followers.paginate :page=>params[:page],:per_page=>5
    render :action=>"show"

  end

  def comments
  respond_to do |format|
      format.html do
        @sidebar = { :partial => "projects/sidebar", :locals => { :project => @project } }
      end
      format.atom do
        @activities = Activity.for_project(@project).latest(10)
      end
    end
     
    render :action=>"show"

  end


   

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      @project.memberships.create(:profile => current_profile, :originator => true,:like_to_join=>"interestedproject")
      project = @project
      redirect_to dashboard_url
    else
      add_form_error
      category_validation
      render :action => 'new'
    end
  end
  
  def image_uploadify
    load_project
    respond_to do |format|
      format.json do
        if @project.update_attributes(:images_attributes => [{ :attachment => params["Filedata"] }])
          render :json => { :result => 'success' }
        else
          render :json => { :result => 'error' }
        end
      end
    end
  end
  
  def edit
    render
  end

  def edit_images
    render
  end

  def update
    if @project.update_attributes(params[:project])
      redirect_to dashboard_path
    else
      category_validation
      render :action => :edit
    end
  end

  def my_projects
    @projects = current_profile.projects_by_type
  end

  def follow
    @follow = current_profile.follow_project(@project)
    @activity_feed_follower = Activity.create(:subject_id => @follow.id,:subject_type=> "Interest",:profile_id => current_profile.id,:project_id=>@project.id)
    if  !@project.originators.empty? && !@project.followups.collect(&:email).empty?
      @project.followups.each do |user|
        Mailer.send_later(:deliver_follows_project_to_originator,@project,current_profile,user.display_name,user.email)
      end
    end

    if  !@project.members.empty? && !@project.followups_members.collect(&:email).empty?
      @project.followups_members.each do |user|
        Mailer.send_later(:deliver_follows_project_to_collaborators,@project,current_profile,user.display_name,user.email)
      end
    end

    redirect_to :back
  end

  def join
    current_profile.join_project(@project)
    redirect_to :back
  end

  # AJAX endpoint

  def slug_check
    slug = params[:title].to_slug
    render :json => {:slug => slug, :unique => Project.count(:conditions => ['slug = ?', slug]) == 0}
  end
  


  private

  def set_console_section
    @console_section = :projects
  end

  
   def category_validation
  if params[:project][:projectcategory_id].blank?
        @text="can't be blank"
      end
  end

end
