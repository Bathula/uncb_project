class AddColumnToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :category_id, :integer,:null => false
  end

  def self.down
    remove_column :services, :category_id
  end
end
