class AddNewsletterToProfiles < ActiveRecord::Migration
  def self.up
    change_column_default(:profiles,:active,0)
    add_column :profiles, :newsletter, :boolean,:null => false,:default => 0
  end

  def self.down
     remove_column :profiles, :newsletter
    end
end
