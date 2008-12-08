class UndoFixToRatings < ActiveRecord::Migration
  def self.up
    remove_column :ratings, :value
    add_column :ratings, :value_id, :integer, :null => false
  end

  def self.down
  end
end
