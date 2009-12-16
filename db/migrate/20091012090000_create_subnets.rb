class CreateSubnets < ActiveRecord::Migration
  def self.up
    create_table :subnets do |t|
      t.string :name
      t.integer :ip
      t.integer :prefix_length
      t.integer :max_hosts
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :subnets
  end
end
