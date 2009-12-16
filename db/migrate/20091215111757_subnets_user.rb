class SubnetsUser < ActiveRecord::Migration
  def self.up
    add_column :subnets, :user_id, :integer, :default => 1, :nil => false
  end

  def self.down
    remove_column :subnets, :user_id
  end
end
