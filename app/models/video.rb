#

class Video < ActiveRecord::Base
  belongs_to :episode
  serialize :yahoo_video#, Yahoo::Music::Video
end
