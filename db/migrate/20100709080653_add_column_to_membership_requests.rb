class AddColumnToMembershipRequests < ActiveRecord::Migration
  def self.up
    add_column :membership_requests, :like_to_join, :string
  end

  def self.down
    remove_column :membership_requests, :like_to_join
  end
end
