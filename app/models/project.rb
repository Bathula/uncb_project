class Project < ActiveRecord::Base
	
  #------------------------------------------------------------
  # Constants
  #------------------------------------------------------------

  # Field lengths to be used in migrations, html element lengths & validation
  ATTR_LENGTHS = {
    :membership_status => 30,
    :title             => 255,
  }

  MEMBERSHIP_STATUS_OPEN   = 'open'
  MEMBERSHIP_STATUS_INVITE = 'invite'
  MEMBERSHIP_STATUS_CLOSED = 'closed'

  MEMBERSHIP_STATUSES = [
    MEMBERSHIP_STATUS_OPEN,
    MEMBERSHIP_STATUS_INVITE,
    MEMBERSHIP_STATUS_CLOSED ]

  #------------------------------------------------------------
  # ActiveRecord Declarations
  #------------------------------------------------------------
  mount_uploader :avatar, AvatarUploader
  belongs_to:projectcategory
  has_many :images, :as => :attachable, :dependent => :destroy
  accepts_nested_attributes_for(:images, :allow_destroy => true,
    :reject_if => lambda { |attrs| attrs['attachment'].blank? } )

#	has_many :user_ratings, :through=> 'ratings'

   belongs_to :batch
acts_as_rateable
  
  has_many :memberships, :dependent => :destroy
  has_many :profiles, :through => :memberships
  has_many :originators, :through => :memberships, :source => :profile,
    :conditions => ["originator = ?", true]
  has_many :members, :through => :memberships, :source => :profile,
    :conditions => ["originator = ?", false]
  has_many :interests, :dependent => :destroy
  #knowing follow true or false from memberships table for originator
  has_many:followups,:through => :memberships, :source => :profile,
    :conditions => ["follow=? AND originator=? ",true,true]
  #knowing follow true or false from memberships table for members
  has_many:followups_members,:through => :memberships, :source => :profile,
    :conditions => ["follow=? AND originator=? ",true,false]
  #knowing originator's flag in membership table for originator
  has_many:join_projects_orig,:through => :memberships, :source => :profile,
    :conditions => ["join_project=? AND originator=? ",true,true]
  has_many:join_members,:through => :memberships, :source => :profile,
    :conditions => ["join_project=? AND originator=? ",true,false]
  ### for open projects
  has_many:open_originator,:through => :memberships, :source => :profile,
    :conditions => ["open_join=? AND originator=? ",true,true]
  has_many:open_members,:through => :memberships, :source => :profile,
    :conditions => ["open_join=? AND originator=? ",true,false]
  #blog post for collaborators from membership table
  has_many:blog_post_collaborators,:through => :memberships, :source => :profile,
    :conditions => ["blog_post=? AND originator=? ",true,false]
  #blog post for followers
  has_many:blog_post_followers,:through => :interests, :source => :profile,
    :conditions => ["blog_post=? ",true]
  #blog comments flag to members
  has_many:comments_collaborators,:through => :memberships, :source => :profile,
    :conditions => ["comments=? AND originator=? ",true,false]
  #blog comments followers checking flag in interests table
  has_many:comments_followers,:through => :interests, :source => :profile,
    :conditions => ["comments=?",true]
  #blog comments checking flag in memberships table for originator
  has_many:comments_originator,:through => :memberships, :source => :profile,
    :conditions => ["comments=? AND originator=? ",true,true]
  #blog post comments checking for originator
  has_many:blog_comments_originator,:through => :memberships, :source => :profile,
    :conditions => ["blog_comments=? AND originator=? ",true,true]
  #blog post comments for members
  has_many:blog_comments_collaborators,:through => :memberships, :source => :profile,
    :conditions => ["blog_comments=? AND originator=? ",true,false]
  #blog post commnets for followers
  has_many:blog_comments_followers,:through => :interests, :source => :profile,
    :conditions => ["blog_comments=?",true]
  has_many:likes_originator,:through => :memberships, :source => :profile,
    :conditions => ["like_to=? AND originator=?",true,true]

  has_many:likes_collaborators,:through => :memberships, :source => :profile,
    :conditions => ["like_to=? AND originator=? ",true,false]


  has_many :followers, :through => :interests, :source => :profile
  has_many :users,:through => :membership_requests, :source => :profile
  has_many :membership_requests, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :likes, :dependent => :destroy
  has_many :blog_entries, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  has_many :links, :class_name => 'ProjectLink', :dependent => :destroy
  accepts_nested_attributes_for(:links, :allow_destroy => true,
    :reject_if => lambda { |attrs| attrs['url'].blank? } )
  before_validation_on_create :slugify

  named_scope :active, :conditions => { :active => true }
  named_scope :public, :conditions => { :public => true }
  named_scope :visible, :conditions => { :active => true, :public => true }
  named_scope :category, lambda { |category| {:conditions => {:projectcategory_id => category}}}

  named_scope :by_title, :order => 'projects.title ASC'
  named_scope :featured, { :conditions => { :featured => true } }

  opw_validate_lengths(ATTR_LENGTHS)
  validates_inclusion_of :membership_status, :in => MEMBERSHIP_STATUSES
  #validates_presence_of :title, :description, :short_description, :projectcategory
  validates_presence_of :title, :description, :short_description
  validates_length_of :short_description, :maximum => 150, :allow_nil => true
  validates_presence_of :slug
  validates_uniqueness_of :slug
  acts_as_taggable_on :tags




 

  define_index do
    indexes title
    indexes description
    indexes short_description
    indexes current_resources
    indexes resources_needed
    indexes needs
    indexes url
    indexes tags.name, :as => :tags
    where "public = 1 AND active=1"
    set_property :delta => true
  end

  #------------------------------------------------------------
  # Instance Methods
  #------------------------------------------------------------

  def typus_name
    title
  end

  def avatar_url(size = :avatar)
    if avatar.present?
      avatar.url(size)
    elsif images.count > 0
      images.first.attachment.url(size)
    else
      ""
    end
  end

  def add_participant(profile, originator = false)
    self.membership_requests.first(:conditions => { :profile_id => profile.id }).try(:destroy)
    self.memberships.create(
      :profile  => profile,
      :originator => originator,:like_to_join => "interested" )
  end

  def promote_profile_to_originator(profile)
    # TODO: If entry exists for profile, change it.
    self.add_participant(profile, true)
  end

  def slugify
    self.slug ||= self.title.try( :to_slug )
  end

  MEMBERSHIP_STATUSES.each do |status|
    define_method "has_#{status}_membership?" do
      self.membership_status == status
    end
  end

  def to_param
    slug || id
  end

  def next
    puts"==========================next=============================="
#    project = Project.public.find(:all, :conditions => ['rating_cache < ? ', rating_cache], :order => 'rating_cache DESC')
#    puts "next.....!"
#    p project
#    project || Project.public.first(:order => 'rating_cache DESC')

  project = Project.public.find(:all,:order => 'rating_cache DESC')
  c=project.index(self)
  project[c+1]|| Project.public.first(:order => 'rating_cache DESC')
#    puts "next.....!"
#    p project
  end

  def previous
     puts"==========================previous=============================="

#    project = Project.public.find(:first, :conditions => ['rating_cache > ?', rating_cache], :order => 'rating_cache ASC')
#    project || Project.public.first(:order => 'rating_cache ASC')
#    puts"previuos....!"
#     p project
#      puts"previuos....!"
project = Project.public.find(:all,:order => 'rating_cache DESC')
  c=project.index(self)
  project[c-1]|| Project.public.last(:order => 'rating_cache DESC')
  end

  def non_member_followers
    @non_member_followers ||= self.followers - self.profiles
  end

  # Requests slicing to  first  4 projects
  def self.request(current_profile)
    @orig_proj = current_profile.originated_projects.collect(&:id)
    @req = MembershipRequest.find(:all,:conditions=>['project_id IN(?)',@orig_proj]).collect(&:project_id).uniq
    @all_projects = Project.find_all_by_id(@req)
  end
#def rate_it(score, user, user_is_pro)
#          create_rating unless rating
#          rating.rate(score, user, user_is_pro)
#        end

  def update_ratings_cache
					self.rating_count_cache = ratings_count
					self.rating_count_cache_pro = ratings_count_pro

					
						self.rating_cache = average_rating
					
				

					self.rating_cache_pro = average_rating_pro
#puts "=========================update_ratings_cache===================================="
#		puts self.rating_cache
#    puts "=========================update_ratings_cache===================================="

    self.save!
	end
#def update_rating
#
#  puts "ppppppppppppppppppppppppppppppp"
#    self.average_rating = user_ratings.average(:score,:conditions => ['is_pro = NULL OR is_pro = false'])
#    #self.average_rating = user_ratings.average(:score)
#    self.average_rating_pro = user_ratings.average(:score,:conditions => ['is_pro = ?', true])
#    #self.ratings_count = user_ratings.count(:conditions => ['is_pro !=  1'])
#    self.ratings_count = user_ratings.count(:conditions => ['is_pro = NULL OR is_pro = false'])
#    self.ratings_count_pro = user_ratings.count(:conditions => ['is_pro = ?', true])
#    save!
#  end
#

        # Returns the average rating. Calculation based on the already given scores.
#        def average_rating
#          rating && rating.average_rating || 0.0
#        end
#
#        # Returns the average rating. Calculation based on the already given scores.
#        def average_rating_pro
#          rating && rating.average_rating_pro || 0.0
#        end
#
#        # Rounds the average rating value.
#        def average_rating_round
#          average_rating.round
#        end
#
#        # Returns the average rating in percent.
#        def average_rating_percent
#          f = 100 / max_rating.to_f
#          average_rating * f
#        end
#
#        # Returns the number of ratings.
#        def ratings_count
#          rating && rating.ratings_count || 0
#        end
#
#        def ratings_count_pro
#          rating && rating.ratings_count_pro || 0
#        end
#
#        # Checks whether a user rated the object or not.
#        def rated_by?(user)
#          rating && rating.user_ratings.exists?(:user_id => user)
#        end
#
#        # Returns the rating a specific user has given the object.
#        def rating_by(user)
#          user_rating = rating && rating.user_ratings.find_by_user_id(user.id)
#          user_rating ? user_rating.score : nil
#        end
#





  private

  def make_connection( attachment )
    attachment.attachable = self
  end










end

# Project.acts_as_taggable
