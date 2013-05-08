class ProjectLink < ActiveRecord::Base
  belongs_to :project
  
  validates_presence_of :project, :url
end
