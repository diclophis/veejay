class RenameStatusToState < ActiveRecord::Migration
  def self.up
    remove_column :people, :status
    add_column :people, :state, :string, :null => :no, :default => "pending" 
  end

  def self.down
  end
end
