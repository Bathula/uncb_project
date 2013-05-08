class CreateProjectLinks < ActiveRecord::Migration
  def self.up
    create_table :project_links do |t|
      t.references :project, :null => false
      t.string :url, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :project_links
  end
end