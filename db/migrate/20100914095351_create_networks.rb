class CreateNetworks < ActiveRecord::Migration
  def self.up
    create_table :networks do |t|
      t.integer :profile_id
      t.integer :member_id
      t.integer :status

      t.timestamps
    end
  end

  def self.down
    drop_table :networks
  end
end
