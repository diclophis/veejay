class CreateVideosAndEpisodes < ActiveRecord::Migration
  def self.up
    create_table :episodes do |t|
      t.integer :person_id
      t.string :title
      t.datetime :airs_on
      t.text :description
      t.timestamps
    end

    create_table :videos do |t|
      t.integer :episode_id
      t.string :yahoo_id
      t.string :yahoo_title
      t.integer :yahoo_duration
      t.string :yahoo_images
      t.integer :yahoo_copyright_year
      t.boolean :yahoo_explicit
      t.integer :yahoo_flags
      t.timestamps
    end
  end

  def self.down
    drop_table :episodes
    drop_table :videos
  end
end
