class AddAverageRatingProToRatings < ActiveRecord::Migration
  def self.up
    add_column :ratings, :average_rating_pro, :integer
  end

  def self.down
    remove_column :ratings, :average_rating_pro
  end
end
