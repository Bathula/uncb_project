class InboxesController < ApplicationController
  before_filter :require_profile
  before_filter :add_console
  before_filter :set_console_section
  before_filter :store_location
  # GET /inboxes
  # GET /inboxes.xml


  def show_message
    
    @msg_count=MessageCopy.show_messages(current_profile.id).size
    @message = Message.find(params[:id].slice(10..-1))
 
   # if @message.from_id.eql?(current_profile.id)
     @reply=params[:reply]
     @replyto=params[:rto]
    
    @imessage=Message.new
    if !@replyto.eql?("sent")&& !@message.from_id.eql?(current_profile.id)

      @unread_message=MessageCopy.find_by_message_id_and_recipient_id(params[:id].slice(10..-1),current_profile.id)
      @unread_message.update_attributes(:status=>'read')
     
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @message }
    end
    #else
     # render :text =>"<h1>Only the recipients can view this message.</h1>",:layout=>true
    end
  


  def list_unread
    @unread_messages=MessageCopy.show_messages(current_profile.id)
    @msg_count = @unread_messages.size
    sort = case params['sort']
    when ""  then "created_at DESC"
    end
    if !params['sort']
      sort = "created_at DESC"
    end
    page = params[:page] || 1
    @imessages = @unread_messages.paginate :page => params[:page], :order => sort, :per_page => 5
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inboxes }
      format.json  { render :json => @options }
    end
  end

 
  def show_sent
    #@imessages=Message.show_sent_messages(current_profile)
    p @imessages = Message.find(:all,:conditions=>['from_id=? AND deleted_from=?',current_profile.id,0],:order=>'created_at DESC')
#@imessages.each do |m|
# p m.recipients.collect{|f| f.id}.delete_if{|x| x=""}
#
#
#
#end


   @msg_count=MessageCopy.show_messages(current_profile.id).size
    @imessages = @imessages.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 5
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @imessage }
    end
  end

  def compose
    if params[:type].eql?("service")
      @profiles = Profile.originator_id(params[:orig_id])
    end
    if params[:type].eql?("project")
      @project=Project.find_by_id(params[:orig_id])
      @profiles=@project.originators
    end
    @message = Message.new
    @msg_count=MessageCopy.show_messages(current_profile.id).size
    respond_to do |format|
      format.html { render :layout => 'inboxes'}
    end
  end

  def create
     
    @imessage = Message.new(params[:message])
    @count=1
    $message_id=""

     @imessage=Message.create(:from_id => current_profile.id,:to_id => "",:subject => params[:message][:subject],:body=> params[:message][:body])
    params[:uids].split(':').each do |message|
      if  message != "nil"
       #@imessage=Message.create(:from_id => current_profile.id,:to_id => message,:subject => params[:message][:subject],:body=> params[:message][:body])
       
       if @count.eql?(1)
         
         $message_id=@imessage.id
       end
      

        @count=@count+1
       @message_copies =MessageCopy.create(:recipient_id=>message,:message_id=>$message_id)
       p @recipent_profile=Profile.find(message)
        
    
        
        if @recipent_profile.message_setting.messages_sent.eql?(true)
        Mailer.send_later(:deliver_email_send_to_network_member,current_profile,@recipent_profile,params[:message][:body],@imessage)
        end

        
     
      end
      
    end
   if !params[:attachment].nil?
           params[:attachment].each do |attachment|

           @imessage.message_attachments.create(:data => attachment)
           end
      end
  


    #respond_to do |format|
      if @imessage.save
        add_notice "Your message has been sent."
        if params[:redirect].eql?("sent")
         redirect_to('/inbox/sent') 
        elsif params[:redirect].eql?("unread")
          redirect_to('/inbox/unread') 
        else
           redirect_to('/inbox/') 
        end
      else
      add_attachment_error
       render :action => :compose
        #format.xml  { render :xml => @imessage.errors, :status => :unprocessable_entity }
      #end
    end
  end 

 







  def search_usernames
    term = params[:term]
    # @member=Network.members(current_profile).collect(&:member_id)
     #@profiles = Profile.find_by_sql" SELECT display_name,profiles.id FROM profiles,networks where  profiles.id=networks.member_id and  networks.profile_id=#{current_profile.id} and display_name like '%#{term}%'"

    @profiles = Profile.find_by_sql" SELECT display_name,profiles.id FROM profiles where  display_name like '#{term}%' AND active='1'  AND deleted_at IS NULL and profiles.id != #{current_profile.id}"
    respond_to do |format|
      format.html { render  :json => @profiles }
      format.js { render  :json => @profiles }
    end
  end

  def delete_message
    if params[:un].eql?("s")
    @imessage=Message.find(params[:id].slice(10..-1))
    @imessage.update_attribute :deleted_from,1
    else
      @imessage=MessageCopy.find_by_message_id_and_recipient_id(params[:id].slice(10..-1),current_profile.id)
   

   

#     if @imessage.message.from_id.eql?(current_profile.id)
#      if @imessage.message.from_id.eql?(@imessage.recipient_id)
#        @imessage.update_attributes(:deleted_from=>1,:deleted_to=>1)
#      else
#        @imessage.update_attribute :deleted_from,1
#      end
#    else
      @imessage.update_attribute :deleted_to,1
    end

     



    if params[:un].eql?("u")
      redirect_to '/inbox/unread'
    elsif params[:un].eql?("s")
      redirect_to '/inbox/sent'
    else
      redirect_to '/inbox/'
    end
  end


  def delete_selected_message

    params[:delete_ids].split(':').each do |messageid|


#    @imessage=Message.find_by_id(messageid)
#
#    if @imessage.from_id.eql?(current_profile.id)
#
#    if @imessage.from_id.eql?(@imessage.to_id)
#
#     @imessage.update_attributes(:deleted_from=>1,:deleted_to=>1)
#        else
#
#    @imessage.update_attribute :deleted_from,1
#    end
#    else
#     @imessage.update_attribute :deleted_to,1
#    end

      if params[:un].eql?("s")
    @imessage=Message.find(messageid)
    @imessage.update_attribute :deleted_from,1
    else
      @imessage=MessageCopy.find_by_message_id_and_recipient_id(messageid,current_profile.id)


      @imessage.update_attribute :deleted_to,1
    end
    end
    if params[:un].eql?("u")
      redirect_to '/inbox/unread'
    elsif params[:un].eql?("s")
      redirect_to '/inbox/sent'
    else
    redirect_to '/inbox/'
    end

  end



  def all  
    @imessages = MessageCopy.all(current_profile)
    @msg_count=MessageCopy.show_messages(current_profile.id).size
    sort = case params['sort']
    when ""  then "created_at DESC"
    end
    if !params['sort']
      sort = "created_at DESC"
    end
    page = params[:page] || 1
    @imessages =     @imessages.paginate :page => params[:page], :order => sort, :per_page => 5
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inboxes }
      format.json  { render :json => @options }
    end
  end
  private
  def set_console_section
    @console_section = :inbox
  end
end