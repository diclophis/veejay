class AddRatingCacheToEpisodes < ActiveRecord::Migration
  def self.up
    add_column :episodes, :ratings_count, :integer, :default => 0, :null => false
    add_column :episodes, :rating, :float, :precision => 3, :scale => 2, :default => 0, :null => false
  end

  def self.down
  end
end
