class ActsAsArchive < ActiveRecord::Migration
  def self.up
  add_column :profiles, :deleted_at, :timestamp
  add_column :networks, :deleted_at,:timestamp
  end

  def self.down
    remove_column :profiles, :deleted_at
    remove_column :networks, :deleted_at
  end
end
