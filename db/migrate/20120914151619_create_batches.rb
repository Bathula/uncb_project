class CreateBatches < ActiveRecord::Migration
  def self.up
    create_table :batches do |t|
      t.string :name
    end
    add_column :projects, :batch_id, :string
   
  end

  def self.down
    drop_table :batches
    remove_column :projects, :batch_id, :string
    
  end
end
