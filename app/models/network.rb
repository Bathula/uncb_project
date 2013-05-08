class Network < ActiveRecord::Base
  belongs_to :profile
  belongs_to :member, :class_name => 'Profile'


named_scope :members,lambda { |current_profile| {:conditions=>['profile_id=? AND status=?',current_profile.id,0]}}

  acts_as_paranoid


end
