class NodesUser < ActiveRecord::Migration
  def self.up
    add_column :nodes, :user_id, :integer, :default => 1, :nil => false
  end

  def self.down
    remove_column :nodes, :user_id
  end
end
