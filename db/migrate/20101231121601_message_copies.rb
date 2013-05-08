class MessageCopies < ActiveRecord::Migration
  def self.up
    create_table :message_copies do |t|
     t.integer :recipient_id
     t.integer :message_id 
     t.integer :deleted_to,:default => 0
     t.integer :deleted_from,:default => 0
     t.string :status,:default=>"unread"
     t.timestamps
    end
  end

  def self.down
    drop_table :message_copies
  end
end
