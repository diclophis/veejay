class FixRatings < ActiveRecord::Migration
  def self.up
    remove_column :ratings, :value_id
    add_column :ratings, :value, :float, :null => false
  end

  def self.down
  end
end
