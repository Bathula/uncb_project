class AddIsProToUserRatings < ActiveRecord::Migration
  def self.up
    add_column :user_ratings, :is_pro, :boolean
  end

  def self.down
    remove_column :user_ratings, :is_pro
  end
end
