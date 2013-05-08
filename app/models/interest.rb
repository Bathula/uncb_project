class Interest < ActiveRecord::Base
  belongs_to :profile
  belongs_to :project

  validates_presence_of :profile
  validates_presence_of :project
  validates_uniqueness_of :profile_id, :scope => :project_id



  def self.follower(project,id)
  @follower = Interest.find_by_project_id_and_profile_id(project,id)
  end
end
