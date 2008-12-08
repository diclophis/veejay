class FixStateDefaultValue < ActiveRecord::Migration
  def self.up
    remove_column :people, :state
    add_column :people, :state, :string, :null => :no, :default => "passive" 
  end

  def self.down
  end
end
