class AddInboxVars < ActiveRecord::Migration
  def self.up
  add_column :inboxes, :user, :string
  end

  def self.down
  end
end
