class IndexSubnetsOnName < ActiveRecord::Migration
  def self.up
    add_index :subnets, [ :name ], :unique => true
  end

  def self.down
    remove_index :subnets, [ :name ]
  end
end
