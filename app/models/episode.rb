#

class Episode < ActiveRecord::Base
  belongs_to :person
  has_many :videos
end
