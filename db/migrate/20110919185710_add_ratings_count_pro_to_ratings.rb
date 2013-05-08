class AddRatingsCountProToRatings < ActiveRecord::Migration
  def self.up
    add_column :ratings, :ratings_count_pro, :integer
  end

  def self.down
    remove_column :ratings, :ratings_count_pro
  end
end
