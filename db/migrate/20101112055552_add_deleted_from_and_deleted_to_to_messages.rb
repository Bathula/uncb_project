class AddDeletedFromAndDeletedToToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :deleted_from, :int, :default => 0
    add_column :messages, :deleted_to, :int, :default => 0

  end

  def self.down
     remove_column :messages, :deleted_from, :int, :default => 0
     remove_column :messages, :deleted_to, :int, :default => 0
  end
end
