class AddIsProToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :is_pro, :boolean
  end

  def self.down
    remove_column :profiles, :is_pro
  end
end
