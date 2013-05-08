class ChangeUsernamefieldDefaultValueToNull < ActiveRecord::Migration
  def self.up
    change_column :profiles, :username, :string, :null => true, :default => nil
  end

  def self.down
    change_column :profiles, :username, :string, :null => false, :default => nil
  end
end
