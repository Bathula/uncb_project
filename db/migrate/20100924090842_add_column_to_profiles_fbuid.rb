class AddColumnToProfilesFbuid < ActiveRecord::Migration
  def self.up
    add_column :profiles, :facebook_id, :integer, :limit=>8
    add_column :profiles, :session_key, :string
    
  end

  def self.down
    remove_column :profiles,  :facebook_id
    remove_column :profiles,  :session_key
  end
end
