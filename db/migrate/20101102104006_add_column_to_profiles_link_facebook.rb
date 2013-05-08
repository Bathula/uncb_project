class AddColumnToProfilesLinkFacebook < ActiveRecord::Migration
  def self.up
     add_column :profiles, :network, :string
  
  end

  def self.down
     remove_column :profiles, :network, :string
    
  end
end
