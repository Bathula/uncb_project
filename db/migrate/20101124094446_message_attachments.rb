class MessageAttachments < ActiveRecord::Migration
  def self.up
    create_table :message_attachments do |t|
      t.string :data_file_name
      t.string :data_content_type
      t.integer :data_file_size
      t.integer :attachable_id
      t.string :attachable_type
      t.timestamps
    end

    add_index :message_attachments, [:attachable_id, :attachable_type]
  end

  def self.down
     drop_table :message_attachments
  end
end
