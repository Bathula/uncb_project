class AddColumnToProjects < ActiveRecord::Migration
  def self.up
    add_column :memberships, :blog_comments, :boolean, :null => false, :default => true
    add_column :memberships, :follow, :boolean, :null => false, :default => true
    add_column :memberships, :join_project, :boolean, :null => false, :default => true
    add_column :memberships, :like_to, :boolean, :null => false, :default => true
    add_column :memberships, :blog_post, :boolean, :null => false, :default => true
    add_column :memberships, :comments, :boolean, :null => false, :default => true
    add_column :interests, :blog_comments, :boolean, :null => false, :default => true
    add_column :interests, :follow, :boolean, :null => false, :default => true
    add_column :interests, :join_project, :boolean, :null => false, :default => true
    add_column :interests, :like_to, :boolean, :null => false, :default => true
    add_column :interests, :blog_post, :boolean, :null => false, :default => true
    add_column :interests, :comments, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :memberships, :blog_comments
    remove_column :memberships, :follow
    remove_column :memberships, :join_project
    remove_column :memberships, :like_to
    remove_column :memberships, :blog_post
    remove_column :memberships, :comments

    remove_column :interests, :blog_comments
    remove_column :interests, :follow
    remove_column :interests, :join_project
    remove_column :interests, :like_to
    remove_column :interests, :blog_post
    remove_column :interests, :comments
  end
end
