class AddRatingsCacheProToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :rating_cache_pro, :float
  end

  def self.down
    remove_column :projects, :rating_cache_pro
  end
end
