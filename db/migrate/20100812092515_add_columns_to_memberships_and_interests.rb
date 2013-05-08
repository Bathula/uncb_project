class AddColumnsToMembershipsAndInterests < ActiveRecord::Migration
  def self.up
    add_column :memberships, :like_to_join, :string, :null => false
    add_column :memberships, :open_join, :boolean, :null => false, :default => true
    add_column :interests, :open_join, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :memberships, :like_to_join
    remove_column :memberships, :open_join
    remove_column :interests, :open_join
  end
end
