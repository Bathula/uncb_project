class Profile < ActiveRecord::Base

  #------------------------------------------------------------
  # Constants
  #------------------------------------------------------------

  # Field lengths to be used in migrations, html element lengths & validation
  ATTR_LENGTHS = {
    :city               => 30,
    :country            => 30,
    :display_name       => 30,
    :email              => 100,
    :email_verification => 40,
    :first_name         => 30,
    :last_name          => 30,
    :password_hash      => 128,
    :password_salt      => 40,
    :phone_home         => 25,
    :phone_mobile       => 25,
    :phone_office       => 25,
    :remember_token     => 100,
    :state              => 30,
    :username           => 30,
    :zip                => 10
  }

  #------------------------------------------------------------
  # ActiveRecord Declarations
  #------------------------------------------------------------
  # Inbox 
    has_many :sent_messages, :class_name => "Message", :foreign_key => "from_id"
  has_many :received_messages, :class_name => "MessageCopy", :foreign_key => "recipient_id"
   has_many :message_copies
  has_many :recipients, :through => :message_copies

has_many :authorizations
  has_many :imessages
 has_many:tos,:through=>:imessages
 has_many :imessage_recipients
 has_many :sents,:through=>:imessage_recipients,:source =>:profile
  has_many :sents_author,:through=>:imessage_recipients,:conditions=> "imessage_recipients.deleted_at=1",:source =>:imessage
  # Network
	has_many :user_ratings, :foreign_key => 'user_id'
  has_many :networks
  has_many :members, :through => :networks
####
  has_many :images, :as => :attachable,
    :after_add => :make_connection, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  has_many :projects, :through => :memberships
  has_many :originated_projects, :through => :memberships,
    :conditions => ["originator = ?", true],
    :source => :project
  has_many :member_projects, :through => :memberships,
    :conditions => ["originator = ?", false],
    :source => :project
  has_many :service_memberships, :dependent => :destroy
  has_many :services, :through => :service_memberships
  has_many :originated_services, :through => :service_memberships,
    :conditions => ["originator = ?", true],
    :source => :service
  has_many :member_services, :through => :service_memberships,
    :conditions => ["originator = ?", false],
    :source => :service
  has_many :interests, :dependent => :destroy
  has_many :followed_projects, :through => :interests,
    :source => :project
  has_many :service_interests, :dependent => :destroy
  has_many :followed_services, :through => :service_interests,
    :source => :service
  has_many :membership_requests, :dependent => :destroy
  has_many :service_membership_requests, :dependent => :destroy
  has_many :messages, :foreign_key => "to_id", :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  has_many :links, :class_name => 'ProfileLink', :dependent => :destroy
  has_one  :message_setting
  accepts_nested_attributes_for(:links, :allow_destroy => true,
    :reject_if => lambda { |attrs| attrs['url'].blank? } )

  attr_accessor :tos_accepted
  validates_presence_of:display_name,:message=>"can't be blank"
   #validates_presence_of:username,:message=>"can't be blank"
  #validates_uniqueness_of :username,:on=>:update
   validates_presence_of:email,:message=>"can't be blank"
     validates_uniqueness_of:email,:message=>"already exists"
   validates_format_of :email, :with =>
%r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i,:on=>:update
validates_length_of :password, :minimum=>5, :if => :password_validation_required
validates_length_of :password_confirmation, :minimum=>5, :if => :password_validation_required
  #after_create :follow_original_projects_project
#attr_accessible  :remote_avatar_url,:avatar,:name
  mount_uploader :avatar, AvatarUploader


#include CarrierWave::Mount
#
#   def mount_uploader(column, uploader, options={}, &block)
#     serialization_column = options[:mount_on] || "#{column}_upload"
#
#     options[:mount_on] = serialization_column
#     key serialization_column
#
#     super(column, uploader, options, &block)
#
#     alias_method :read_uploader, :[]
#     alias_method :write_uploader, :[]=
#     after_save "store_#{column}!".to_sym
#     before_save "write_#{column}_identifier".to_sym
#     after_destroy "remove_#{column}!".to_sym
#   end


  acts_as_paranoid
  acts_as_authentic do |c|
    c.validate_email_field = false
    c.validate_login_field = false
    c.login_field = 'email'

  end

  define_index do
    indexes username
    indexes first_name
    indexes last_name
    indexes display_name
    indexes url
    indexes city
    indexes state
    indexes country
    indexes zip
    indexes biography
    indexes education
    indexes employment
    indexes hobbies
    indexes skills
    indexes pastproj
    indexes originalproj
    set_property :delta => true
  end

def password_validation_required
    new_record? || !@password.blank?
  end

#### authlogic email or username
def self.find_by_username_or_email(login)
 find_by_username(login) || find_by_email(login)
end



   def self.for(facebook_id,username,facebook_session=nil)
        returning find_or_create_by_facebook_id(:facebook_id => facebook_id,:username=> username.first(15).gsub(/\s/, '').gsub(/\./, ''),:display_name=> username.first(15).gsub(/\s/, '').gsub(/\./, ''),:password=>"default",:password_confirmation=>"default",:email=>"default@gmail.com",:member_id =>"") do |user|

       unless facebook_session.nil?
            user.store_session(facebook_session.session_key)
          end
        end
      end


      def store_session(session_key)
          if self.session_key != session_key
          update_attribute(:session_key,session_key)
        end
      end

def self.originator_id(orig_id)

find(:all, :select=>"display_name, email, id", :conditions => ["id IN (?)",orig_id])
end





  # Register a new profile:
  # (Hash, String, Boolean) -> [ success::Boolean, Profile ]
  def self.register(attrs, invite_token)
    profile = Profile.new(attrs)
    invite = Invite.find_by_token(invite_token)

    if profile.valid?
      if invite.present? && !invite.accepted?
        profile.save and invite.accept
      else
        profile.errors.add(:invite_token, 'is invalid')
      end
    end

    profile
  end

  ## activity feeds in My activity feed includes feeds on originated,collaborating,followers
  def self.current_my_projects(current_profile)
     current_profile.originated_projects + current_profile.member_projects + (current_profile.followed_projects - current_profile.projects)

  end

  def send_email
    Mailer.deliver_profile(self)
  end

  #------------------------------------------------------------
  # Instance Methods
  #------------------------------------------------------------

  def self.search_display_name_and_email(query)
    result = if query.present?
      all(:conditions => ["display_name LIKE ? OR email LIKE ?", "%#{query}%", "%#{query}%"], :limit => 10)
    else
      []
    end

   #logger.debug(result.map(&:display_name))
    result
  end

	def user_is_pro?
    puts "==================user_is_pro========================="
		if self.is_pro
			true
		else
			false
		end
	end

  def name
    if display_name.present?
      then display_name
    else [first_name, last_name].reject(&:blank?).join(' ')
    end
  end

  def location
    [[city,state,].reject(&:blank?).join(', '), zip].reject(&:blank?).join(" ")
  end

  def set_password(password)
    self.password = self.password_confirmation = password
  end

  def sorter
    [ self.first_name.capitalize, self.last_name, self.city ]
  end

  def follow_project(project)
    interests.create(:project => project)
  end

  def join_project(project)
    membership_requests.create(:project => project) if project.has_open_membership?
  end

  def requested_membership?(project)
    self.membership_requests.all(:conditions => { :project_id => project.id }).any?
  end

  def is_following?(project)
    followed_projects.include?(project)
  end

  def is_involved?(project)
    projects.include?(project)
  end

  def is_member?(project)
    member_projects.include?(project)
  end

  def is_originator?(project)
    originated_projects.include?(project)
  end

  def is_service_owner?(service)
    originated_services.include?(service)
  end


def like_for(project)
    self.likes.first(:conditions => { :project_id => project.id })
  end

  def projects_by_type
    @projects_by_type ||= {
      :originated     => self.originated_projects,
      :collaborating  => self.member_projects,
      :following      => self.followed_projects - self.projects
    }
  end
  # service methods -----------------
  def follow_service(service)
    service_interests.create(:service => service)
  end

  def join_service(service)
    service_memberships.create(:service => service) if service.has_open_service_membership?
  end

  def service_requested_membership?(service)
    self.service_membership_requests.all(:conditions => { :service_id => service.id }).any?
  end

  def service_is_following?(service)
    followed_services.include?(service)
  end

  def service_is_involved?(service)
    services.include?(service)
  end

  def service_is_member?(service)
    member_services.include?(service)
  end

  def service_is_originator?(service)
    originated_services.include?(service)
  end

  def service_like_for(service)
    self.likes.first(:conditions => { :service_id => service.id })
  end

  def services_by_type
    @services_by_type ||= {
      :originated     => self.originated_services,
      :collaborating  => self.member_services,
      :following      => self.followed_services - self.services
    }
  end
  alias_method :service_can_edit?, :service_is_originator?
  alias_method :service_can_manage?, :service_is_originator?
  alias_method :service_can_blog?, :service_is_involved?

  #--- end service methods

  alias_method :can_edit?, :is_originator?
  alias_method :can_manage?, :is_originator?
  alias_method :can_blog?, :is_involved?
  alias_method :can_edit_service?,:is_service_owner?


  def deliver_password_reset_instructions
    reset_perishable_token!
    Mailer.deliver_password_reset(self)
  end

  protected

  def <=>( other )
    self.sorter <=> ( other.try( :sorter ) || [] )
  end

  private

  def follow_original_projects_project
    project = Project.find_by_slug('original-projects-inc')
    follow_project(project) if project.present?
  end
end