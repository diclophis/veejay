class RenameUserToPerson < ActiveRecord::Migration
  def self.up
    remove_column :friendships, :user_id
    add_column :friendships, :person_id, :integer, :null => false
  end

  def self.down
  end
end
