class CreateMusers < ActiveRecord::Migration
  def self.up
    add_column :people, :status, :string, :null => :no, :default => "pending" 
    add_column :people, :crypted_password, :string, :limit => 40
    add_column :people, :salt, :string, :limit => 40
    add_column :people, :remember_token, :string, :limit => 40
    add_column :people, :remember_token_expires_at, :datetime
    add_column :people, :activated_at, :datetime
    add_index :people, :nickname, :unique => true
  end
  def self.down
  end
end
