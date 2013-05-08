class CreateProjectcategories < ActiveRecord::Migration
  def self.up
    create_table :projectcategories do |t|
      t.string :name, :null => false
      t.string :description, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :projectcategories
  end
end
