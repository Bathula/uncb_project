class ChangeNetworkStatusColumnDefaultValue < ActiveRecord::Migration
  def self.up
    change_column :networks, :status, :integer, :null => false, :default => 0
  end

  def self.down
     change_column :networks, :status, :integer, :null => true, :default => nil
  end
end
