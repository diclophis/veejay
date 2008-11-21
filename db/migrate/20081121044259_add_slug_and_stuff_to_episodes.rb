class AddSlugAndStuffToEpisodes < ActiveRecord::Migration
  def self.up
    add_column :episodes, :slug, :string, :null => false
    add_column :episodes, :total_duration, :integer, :null => false
  end

  def self.down
  end
end
