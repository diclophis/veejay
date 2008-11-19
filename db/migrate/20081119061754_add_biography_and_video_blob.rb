class AddBiographyAndVideoBlob < ActiveRecord::Migration
  def self.up
    add_column :people, :biography, :text, :default => nil
    add_column :videos, :yahoo_video, :text, :default => nil
  end

  def self.down
  end
end
