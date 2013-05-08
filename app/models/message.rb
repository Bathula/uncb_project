class Message < ActiveRecord::Base
  belongs_to :to,   :class_name => "Profile"
  belongs_to :from, :class_name => "Profile"
  #has_many :images, :as => :attachable, :dependent => :destroy

   has_many :message_copies
  has_many :recipients, :through => :message_copies


#  accepts_nested_attributes_for(:images, :allow_destroy => true,
#    :reject_if => lambda { |attrs| attrs['attachment'].blank? } )
  has_many  :message_attachments, :as => :attachable, :dependent => :destroy
  #named_scope :show_messages, lambda { |to_id| {:conditions => {:to_id => to_id,:status=>'unread',:deleted_to => 0}}}
   named_scope :show_sent_messages,lambda { |current_profile| {:conditions=>['deleted_from=? AND from_id=?',0,current_profile],:order=> "created_at DESC",:group=>"created_at"}}
   #named_scope :all,lambda { |current_profile| {:conditions=>['deleted_to=? AND to_id=?',0,current_profile],:order=>"created_at DESC"}}

 default_scope :order => 'created_at DESC'

  #validates_presence_of :to
  #validates_presence_of :to,:message=>"can't be blank"
  validates_presence_of :subject,:message=>"can't be blank"
  validates_presence_of :body,:message=>"can't be blank"



  #after_save :send_copies

  def to=(*receivers)
    @copies = receivers.flatten
    write_attribute :to_id, @copies.shift.try(:id)
  end

  def deliver
    Mailer.deliver_user_specified_message(self) if self.save
  end

    

def self.to_param(m)
  Time.now.to_i.to_s + m.id.to_s
end

  private

  def send_copies
    @copies.each do |profile|
      copy = self.clone
      copy.to = profile
      copy.deliver
    end
  end
end
