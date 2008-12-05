class AddRemoteVideoBlob < ActiveRecord::Migration
  def self.up
    add_column :videos, :remote_video, :text, :default => nil
  end

  def self.down
  end
end
