class NetworksController < ApplicationController

  before_filter :require_profile
  before_filter :set_title
  before_filter :set_receivers, :only => :create_message
  before_filter :add_networkconsole
  before_filter :set_console_section
  before_filter :store_location

  # GET /networks
  # GET /networks.xml
def index
      @console_section = :network
    sort = case params['sort']

    when ""  then "username ASC"
    when "z-a"  then "username DESC"
    when "location"   then "city ASC"
    when "recent" then "created_at ASC"

    end
    if !params['sort']
      sort = "id ASC"
    end
    page = params[:page] || 1

     
    
      @current_networks = current_profile.networks.paginate :page => params[:page], :order => sort, :per_page => 5
     
  end


  # GET /networks/1
  # GET /networks/1.xml
  def show
    @network = Network.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @network }
    end
  end

  # GET /networks/new
  # GET /networks/new.xml
  def new
    @message = Message.new(:subject => params[:subject])
     @title    = params[:title];
     params[:to_id]=params[:profile_id]
    respond_to do |format|
      format.html
      format.js {
        render :partial => "form", :locals => {
          :return_to => params[:return_to],
         
#          :resource => @resource,
          :message  => @message
        }
      }
    end
  end


   def create_message
  
    @message      = Message.new(params[:message])
    @message.from = current_profile
 
     @message.to_id=params[:to_id]

    @return_to = networks_url

    if @message.valid? and verify_recaptcha(:model => @message,:message => 'Its error with ReCaptcha')
    
     
      @message.save

      add_notice "Your message was delivered."
      to_profile=Profile.find(params[:to_id])

      Mailer.deliver_mail_to_specified_user_message(to_profile,current_profile,@message.body)
      redirect_to(@return_to)
    else
      add_error @message.errors.full_messages.join("; "), :now => true
      render :action => "new"
      
    end
  end










  # GET /networks/1/edit
  def edit
    @network = Network.find(params[:id])
  end

  # POST /networks
  # POST /networks.xml
  def create

    params[:member_id].split(':').each do |memberid|
      @member=Network.find_by_profile_id_and_member_id(current_profile.id,memberid)
      if !@member    
      @network = current_profile.networks.build(:member_id => memberid)
        if params[:type].eql?("service")
        @network.status=1
      end
      @network.save
      end
    end
    
     add_notice "Contact has been successfully added to your network"
     redirect_to network_url
  end

  # PUT /networks/1
  # PUT /networks/1.xml
  def update
    @network = Network.find(params[:id])

    respond_to do |format|
      if @network.update_attributes(params[:network])
        flash[:notice] = 'Network was successfully updated.'
        format.html { redirect_to(@network) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @network.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /networks/1
  # DELETE /networks/1.xml
  def delete


    if params[:member_id]

    @member_id = Network.find_by_member_id_and_profile_id(params[:member_id],current_profile).id
    @network=current_profile.networks.find(@member_id)
  else
   
   @network = current_profile.networks.find(params[:id])
  end
  
  @network.destroy
       add_notice "Contact has been successfully removed from your network"
  redirect_to networks_url    
  end


  private

    def load_resource
	if params[:profile_id]
      	@resource = Profile.find(params[:profile_id])

	elsif params['return_to'].include?('/services/')
		@resource = load_service
		else
		@resource = load_project
		end

   end

  def set_title
    @title = "the Originators of #{@resource.title}" if @resource.is_a?(Project)
    @title = "the Originators of #{@resource.title}" if @resource.is_a?(Service)
  end

  def set_receivers
    @receivers = @resource.originators if @resource.is_a?(Project)
    @receivers = @resource.originators if @resource.is_a?(Service)
  end




#  def load_profile
#    @profile = if params[:username]
#      Profile.find_by_username(params[:username])
#    else
#      Profile.find(params[:member][:profile_id])
#    end
#  end
#
#  def load_membership
#    @membership = Membership.find_by_project_id_and_profile_id!(@project.id, params[:id])
#  end

  def set_console_section
    @console_section = :networks
  end

end
