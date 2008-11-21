#

class Episode < ActiveRecord::Base
  belongs_to :person
  has_many :videos
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :person_id
  validates_length_of :videos, :minimum => 1, :message => "must be added"
  before_validation :normalize_slug
  def to_param
    [person, slug]
  end
  def normalize_slug
    self.slug = Slugalizer.slugalize(title)
  end
end