class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.string :name
      t.string :street
      t.string :zip
      t.string :city
      t.decimal :lat, :precision => 9, :scale => 6
      t.decimal :lng, :precision => 9, :scale => 6
      t.string :position
      t.text :description
      t.integer :ip
      t.references :subnet
      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end
