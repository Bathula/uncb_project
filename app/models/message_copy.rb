class MessageCopy < ActiveRecord::Base
  belongs_to :message
  belongs_to :recipient, :class_name => "Profile"
default_scope :order => 'created_at DESC'
#  delegate   :author, :created_at, :subject, :body, :recipients, :to => :message
#  scope_out  :deleted
#  scope_out  :not_deleted, :conditions => ["deleted IS NULL OR deleted = ?", false]
named_scope :show_messages, lambda { |to_id| {:conditions => {:recipient_id => to_id,:status=>'unread',:deleted_to => 0}}}
 named_scope :all,lambda { |current_profile| {:conditions=>['deleted_to=? AND recipient_id=?',0,current_profile]}}
  named_scope :show_sent_messages,lambda { |current_profile| {:conditions=>['deleted_from=? AND from_id=?',0,current_profile],:order=> "created_at DESC",:group=>"created_at"}}
end