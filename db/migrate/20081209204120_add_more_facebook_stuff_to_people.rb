class AddMoreFacebookStuffToPeople < ActiveRecord::Migration
  def self.up
    add_column :videos, :comment, :text
  end

  def self.down
  end
end
