class AddColumnToProjectsAgain < ActiveRecord::Migration
  def self.up
     add_column :projects, :projectcategory_id, :integer,:null => false
  end

  def self.down
      remove_column :projects, :projectcategory_id
  end
end
