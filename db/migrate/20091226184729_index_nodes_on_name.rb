class IndexNodesOnName < ActiveRecord::Migration
  def self.up
    add_index :nodes, [ :name ], :unique => true
  end

  def self.down
    remove_index :nodes, [ :name ]
  end
end
