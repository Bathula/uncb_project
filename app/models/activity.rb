class Activity < ActiveRecord::Base
  validates_presence_of :subject
  
  belongs_to :profile
  belongs_to :project
  belongs_to :subject, :polymorphic => true
  
  named_scope :for_project, lambda { |project| {:conditions => {:project_id => project.id}}}
  named_scope :for_projects, lambda { |projects,profile| {:order =>'created_at DESC',:conditions => ['project_id IN(?) AND created_at >= (?)',projects.map(&:id),profile ]}}
  named_scope :for_profile, lambda { |profile| {:conditions => ['profile_id=? AND project_id IS NOT NULL',profile.id]}}
  named_scope :latest, lambda { |n| {:limit => n, :order => 'created_at ASC'} }
  named_scope :for_profile_recent, lambda { |profile| {:conditions => ['profile_id=? AND project_id IS NOT NULL',profile.id]}}
end
