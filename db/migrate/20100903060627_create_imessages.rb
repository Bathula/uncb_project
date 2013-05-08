class CreateImessages < ActiveRecord::Migration
  def self.up
    create_table :imessages do |t|
      t.string :subject
      t.text :content
      t.integer :to
      t.integer :profile_id

      t.timestamps
    end
  end

  def self.down
    drop_table :imessages
  end
end
