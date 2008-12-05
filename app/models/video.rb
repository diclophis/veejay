#

class Video < ActiveRecord::Base
  belongs_to :episode
  serialize :remote_video
end
