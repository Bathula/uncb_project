ActionController::Routing::Routes.draw do |map|
  map.resources :batches

  map.resources :message_attachments
  #map.resources :imessage_recipients
  #map.resources :imessages,:collection=>{:show_sent=>:get}
  map.resources :inboxes
  map.resources :authentications

  map.with_options(:controller => 'inboxes') do |i|    # message views
    i.inbox            '/inbox/', :action => 'all' #unread View - Default
    i.inbox            '/inbox/sent', :action => 'show_sent' #show all messages
    i.inbox            '/inbox/unread',:action => 'list_unread' ## show unread messages
    #i.inbox            '/inbox/message/:id', :controller => 'inboxes', :action => 'show_message' #view single message
   # i.inbox             '/inbox/deletemessage/:id',:controller=>'inboxes',:action => 'delete_message'
    i.inbox            '/inbox/compose', :controller => 'inboxes', :action => 'compose' #create new message
    # for AJAX JSON services
    i.inbox            '/inboxes/api/profiles/',  :action => 'list_profiles'
    i.inbox            '/inboxes/api/profiles/search/',  :action => 'search_usernames'
    i.inbox            '/inboxes/deleteselectedmessage',:controller=>'inboxes',:action=>'delete_selected_message'
  end
 map.inbox_message('/inbox/message/:id', :controller => 'inboxes', :action => 'show_message')
 map.delete_message('/inbox/deletemessage/:id',:controller=>'inboxes',:action => 'delete_message')

 # match '/inbox/messages/:id' => 'imessages#show'
 # map.inbox '/inbox/messages/:id', :controller => 'imessages', :action => 'show'


  map.resources :networks,:collection=>{:delete=> :delete,:create_message=>:post}
map.with_options(:controller => 'networks') do |network|
    network.network '/network', :action => :index, :conditions => { :method => :get }
end
  map.resources :projectcategories


  map.resources :accesses,:collection=>{:collaborators => :get,:collaborators_open=>:get,:collaborators_open_update=>:put,
    :collaborator_update => :put,:originated => :get,:originated_open => :get,
    :originated_update => :put,:follow => :get,:follow_update => :put,
    :follow_open=>:get,:follow_open_update=>:put,:account_settings=>:get,
    :password=>:get,:password_update=>:put,:fb_disconnect=>:post,
    :linkedin_disconnect=>:post,:email_linkedin=>:get,
    :delete_profile_account=>:get,:message_settings=>:get,:message_settings_update=>:put ,:delete_account=>:post}
   map.facebook_op '/fb_with_op', :controller => 'accesses', :action => 'fb_with_op',:method=>:get
  map.with_options :controller => "accesses" do |project|
      project.my_settings '/my_settings',:action => :new, :conditions => { :method => :get }
  end
  map.resources :categories
  map.resource :session, :only => [:new, :create, :destroy]
  map.with_options(:controller => 'sessions') do |session|
    session.login "/login", :action => 'new'
    session.logout "/logout", :action => 'destroy'
  end
  map.logout_fb 'logout_fb', :controller => 'sessions', :action => 'logout_facebook'
  map.resources :membership_requests,:member => {:join=>:get,:join_create=>:post,:create_member=>:post}
  map.my_membership_requests('/membership_requests/:id/new',
                   :controller => 'membership_requests', :action => 'new',
                   :conditions => { :method => :get } )




  map.resources( :projects,
    :collection => { :slug_check => :get},
    :member => { :follow => :post,:join_new => :get ,:join => :post, :image_uploadify => :any,:edit_images=>:get }) do |project|
   project.resources :members,:member => { :promote => :post}
    #project.resources :membership_requests ,:member => {:join=>:get,:join_create=>:post}

    project.resources :likes, :only => [:create, :destroy]
    project.resources :comments, :only => :create, :shallow => true do |comment|
      comment.resources :replies, :only => :create
    end
    project.resources :messages, :only => [:new, :create]
    project.resources :blog_entries, :except => :show do |blog_entry|
      blog_entry.resources :remarks, :only => :create
    end
  end

  map.with_options :controller => "images" do |project|
    project.edit_project_images("/projects/:project_id/images/edit",
                                :action => "edit",
                                :conditions => { :method => :get } )
    project.project_images(     "/projects/:project_id/images",
                                :action => "update",
                                :conditions => { :method => :put } )
  end

  map.my_projects( '/my_projects',
                   :controller => 'projects', :action => 'my_projects',
                   :conditions => { :method => :get } )


  # services----------------------
  map.resources( :services,
    :collection => { :slug_check => :get },
    :service_member => { :follow => :post, :join => :post }) do |service|
    service.resources :service_members, :service_member => { :promote => :post }
    service.resources :service_membership_requests
    service.resources :likes, :only => [:create, :destroy]
    service.resources :comments, :only => :create, :shallow => true do |comment|
      comment.resources :replies, :only => :create
    end
    service.resources :messages, :only => [:new, :create]
    service.resources :blog_entries, :except => :show do |blog_entry|
      blog_entry.resources :remarks, :only => :create
    end
  end

  map.with_options :controller => "images" do |service|
    service.edit_service_images("/services/:service_id/images/edit",
                                :action => "edit",
                                :conditions => { :method => :get } )
    service.service_images(     "/services/:service_id/images",
                                :action => "update",
                                :conditions => { :method => :put } )
  end
  map.my_services( '/my_services',
    :controller => 'services', :action => 'my_services',
    :conditions => { :method => :get } )
  #end services --------------------------------

  map.connect 'attachments/create', :controller => 'attachments', :action => 'create'
  map.connect 'attachments/manage', :controller => 'attachments', :action => 'manage'
  map.dashboard( '/dashboard',
    :controller => 'dashboard',
    :action => :show,
    :conditions => { :method => :get } )
  map.with_options(:controller => 'dashboard') do |dashboard|
    [:inbox, :network, :store, :settings].each do |section|
      dashboard.send(section, "/#{section}", :action => section)
    end
  end
    map.resources( :profiles,:collection => {:check_email => :get,:check_username => :get}) do |profile|
    profile.resources :messages, :only => [:new, :create]
  end
  map.with_options(:controller => 'profiles') do |profile|
    profile.new '/new', :action => :new, :conditions => { :method => :get }
    profile.my_profile '/my_profile', :action => :show, :conditions => { :method => :get }
    profile.edit_profile '/my_profile/edit', :action => :edit, :conditions => { :method => :get }
    profile.search '/profiles', :action => :index, :conditions => { :method => :get }
    profile.profile '/profiles/:id', :action => :show, :conditions => { :method => :get }
    profile.connect '/my_profile', :action => :create, :conditions => { :method => :post }
    profile.connect '/my_profile', :action => :update, :conditions => { :method => :put }
  end

  map.resource( :invite_request,
    :only => [ :new, :create ] )
  map.request_invite( '/request_invite',
    :controller => 'invite_requests',:action => 'new' )
  map.signup('/signup',:controller=>'profiles',:action=>'new')

  map.resources :passwords,:collection=>{:email_linkedin => :get,:email_check_update=>:post,:email_checklinkedin_update=>:post,:delete_linkedin=>:get}
  map.send_activation '/send_activation',:controller =>'passwords',:action =>'send_activation',:method=>:post
  map.activation '/activation_link',:controller =>'passwords',:action =>'activation_link'
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
   map.email_entry '/email_check', :controller => 'passwords', :action => 'email_check',:method=>:get
  map.signup_forlinkedin '/signup_forlinkedin', :controller => 'passwords', :action => 'signup_forlinkedin',:method=>:get
  map.search '/search', :controller => 'search'
  map.root :controller => "home"
  # ROUTES TO CLEAN UP / REMOVE ######################
  map.test_token '/test_token', :controller => 'test_token', :action => 'test_token'
  map.with_options(:controller => 'home') do |m|
    m.about            '/about',               :action => 'about'
    m.contact          '/contact',             :action => 'contact'
    m.developers          '/developers',             :action => 'developers'
    m.developer_create '/developer_create',      :action => 'developer_create' ,:method=> :post
    m.tour          '/tour',                   :action => 'tour'
    m.home             '/',                    :action => 'index'
    m.tos              '/tos',                 :action => 'tos'
    m.event              '/event',             :action => 'event'
    m.event2              '/event2',           :action => 'event2'
    m.services_intro      '/services_intro',   :action => 'services_intro'
    m.file_too_large   '/file_too_large',      :action => 'file_too_large'
  end

  map.dashboard      '/dashboard',      :controller => 'dashboard',  :action => 'index'
  map.privacy        '/privacy',        :controller => 'home',       :action => 'privacy'
  map.terms          '/terms',          :controller => 'home',       :action => 'tos'



  map.media( '/:project_id/media',
                   :controller => 'projects',:action=>'media',
                   :conditions => { :method => :get } )
 map.wanted( '/:project_id/wanted',
                   :controller => 'projects',:action=>'wanted',
                   :conditions => { :method => :get } )
 map.blog( '/:project_id/blog',
                   :controller => 'projects',:action=>'blog',
                   :conditions => { :method => :get } )
 map.comments( '/:project_id/comments',
                   :controller => 'projects',:action=>'comments',
                   :conditions => { :method => :get } )
map.team( '/:project_id/team',
                   :controller => 'projects',:action=>'team',
                   :conditions => { :method => :get } )
map.followers( '/:project_id/followers',
                   :controller => 'projects',:action=>'followers',
                   :conditions => { :method => :get } )

  map.ratings '/ratings/rate', :controller => 'ratings',:action => 'rate'
 map.connect '/ratings/:id/average', :controller => 'ratings', :action => 'get_average_rating'
 map.connect '/ratings/:id/average/pro', :controller => 'ratings', :action => 'get_average_rating_pro'
 map.connect '/ratings/:id/count', :controller => 'ratings', :action => 'get_ratings_count'
 map.connect '/ratings/:id/count/pro', :controller => 'ratings', :action => 'get_ratings_count_pro'



  map.auth '/auth/failure', :controller =>
 'profiles', :action => 'failure'
map.auth '/auth/:provider/callback', :controller =>'profiles', :action => 'create'

end
