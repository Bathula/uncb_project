class AddRatingsCountCacheToProjects < ActiveRecord::Migration
  def self.up
		add_column :projects, :rating_count_cache, :integer
  end

  def self.down
  end
end
