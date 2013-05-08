class AddRatingsCacheProCountToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :rating_count_cache_pro, :integer
  end

  def self.down
    remove_column :projects, :ratings_count_cache_pro
  end
end
