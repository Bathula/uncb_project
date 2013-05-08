class Sphinx < ActiveRecord::Migration
  def self.up
  add_column :projects, :delta, :boolean, :default => true,:null => false
  add_column :profiles, :delta, :boolean, :default => true,:null => false
  add_column :services, :delta, :boolean, :default => true,:null => false
    end

  def self.down
    remove_column :projects, :delta
    remove_column :profiles, :delta
    remove_column :services, :delta
  end
end
