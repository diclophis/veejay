#

class Episode < ActiveRecord::Base
  belongs_to :person
  has_many :videos
  validates_presence_of :title
  validates_length_of :videos, :minimum => 1
end
