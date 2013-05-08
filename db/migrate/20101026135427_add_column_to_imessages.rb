class AddColumnToImessages < ActiveRecord::Migration
  def self.up
    add_column :imessages, :status, :string,:default => 'unread'
    add_column :profiles, :member_id, :string
  end

  def self.down
    remove_column :imessages, :status
    remove_column:profiles,:member_id
  end
end
