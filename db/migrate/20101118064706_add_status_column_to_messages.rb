class AddStatusColumnToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :status, :string, :default=>"unread"
  end

  def self.down
     remove_column :messages, :status, :string, :default=>"unread"
  end
end
