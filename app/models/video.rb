#

class Video < ActiveRecord::Base
  belongs_to :episode
end
