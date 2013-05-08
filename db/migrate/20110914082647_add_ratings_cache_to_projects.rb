class AddRatingsCacheToProjects < ActiveRecord::Migration
  def self.up
		add_column :projects, :rating_cache, :float
  end

  def self.down
  end
end
