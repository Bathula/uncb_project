class CreateImessageRecipients < ActiveRecord::Migration
  def self.up
    create_table :imessage_recipients do |t|
      t.integer :imessage_id
      t.integer :profile_id

      t.timestamps
    end
  end

  def self.down
    drop_table :imessage_recipients
  end
end
