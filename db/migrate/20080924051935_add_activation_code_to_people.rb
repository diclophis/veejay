class AddActivationCodeToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :activated, :boolean, :default => false
    add_column :people, :activation_code, :string, :nil => false
  end

  def self.down
  end
end
