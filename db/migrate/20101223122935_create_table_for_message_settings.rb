class CreateTableForMessageSettings < ActiveRecord::Migration
  def self.up
    create_table :message_settings do |t|

      t.integer :profile_id,       :null => false
      t.boolean  :messages_sent, :default => true, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :message_settings
  end
end
